class ImportTeamData
  DATE_FIELDS = %i(updated_at upgraded_at created_at)

  def initialize(data_file)

    PgTeam.delete_all

    $pg_team_attrs ||= PgTeam.new.attributes.symbolize_keys.keys
    $pg_teams_member_attrs ||= Teams::Member.new.attributes.symbolize_keys.keys

    print PgTeam.count

    File.open(data_file) do |file|
      PgTeam.transaction do

        file.each_line.with_index(1) do |line, lineno|
          line = line.chomp.chomp(',')
          next if %w([ ]).include?(line)

          data = process(MultiJson.load(line, symbolize_keys: true))

          team = save_team!(data[:team])

          # at this point `team` is a live ActiveRecord model

          save_team_members!(team, data[:team_members])

          print '.'
        end
      end
    end

    puts PgTeam.count
  end

  private

  def save_team!(data)
    validate_fields!('PgTeam', data, $pg_team_attrs)

    PgTeam.create!(data)
  end

  def save_team_members!(team, data)
    return unless data

    data.each do |team_members|
      validate_fields!('Teams::Member', team_members, $pg_teams_member_attrs)
      team.members.build(team_members)
    end

    team.save!
  end

  def validate_fields!(klass, data, required_keys)
    undefined_keys = data.keys - required_keys
    fail "Undefined keys for #{klass} found in import data: #{undefined_keys.inspect}" unless undefined_keys.empty?
  end

  def process(input)
    data = {team: {}}

    input.each_pair do |key, value|
      next if can_skip?(key, value)

      transform(data, key, prepare(key, value))
    end

    data
  end

  def transform(data, key, value)
    if %i(
          admins
          editors
          interview_steps
          invited_emails
          office_photos
          pending_join_requests
          pending_team_members
          stack_list
          team_locations
          team_members
          upcoming_events
      ).include?(key)
      data[key] = value
    else
      data[:team][key] = value
    end
  end

  def can_skip?(key, value)
    return true if key == :_id
    return true unless value
    return true if value.is_a?(Array) && value.empty?
    return true if value.is_a?(Hash)  && value['$oid'] && value.keys.count == 1

    false
  end

  def prepare(key, value)
    return value if [Fixnum, Float, TrueClass].any? {|type| value.is_a?(type) }
    return value.map { |v| clean(key, v) } if value.is_a?(Array)

    clean(key, value)
  end

  def clean(key, value)
    if value.is_a?(Hash)
      value.delete(:_id)
      DATE_FIELDS.each do |k|
        value[k] = DateTime.parse(value[k]) if value[k]
      end
    else
      if DATE_FIELDS.include?(key)
        value = DateTime.parse(value)
      end
    end

    value
  end
end

# be rake db:drop:all db:create:all db:schema:load db:migrate db:seed ; be rake db:test:prepare ; clear ; be rails runner script/import_team_data.rb
ImportTeamData.new(File.join(Rails.root, 'dump', 'teams_short.json'))
