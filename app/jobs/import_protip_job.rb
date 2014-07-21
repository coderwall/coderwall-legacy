class ImportProtip
  include Sidekiq::Worker

  sidekiq_options queue: :low

  def perform(type, arg1)
    case type
      when 'github_follows'
        import_github_follows(arg1)
      when 'slideshare'
        import_slideshares(arg1)
      when 'subscriptions'
        autosubscribe_users(arg1)
    end
  end

  def import_github_follows(username)
    user = User.find_by_username(username)
    user.build_github_proptips_fast
  end

  def import_slideshares(fact_id)
    Fact.find(fact_id)
    #Importers::Protips::SlideshareImporter.import_from_fact(fact)
  end

  def autsubscribe_users(username)
    user = User.find_by_username(username)
    user.speciality_tags.each do |speciality|
      Tag.find_or_create_by_name(speciality)
      user.subscribe_to(speciality)
    end
  end
end