namespace :search do
  namespace :rebuild do
    desc 'Reindex all the searchable classes'
    task :all => :environment do
      klasses = [Team, Protip, Opportunity]
      klasses.each do |klass|
        reindex_class(klass)
      end
    end

    desc 'Reindex teams'
    task :teams => :environment do
      reindex_class(Team)
    end

    desc 'Reindex protips'
    task :protips => :environment do
      reindex_class(Protip)
    end

    desc 'Reindex opportunities'
    task :opportunities => :environment do
      reindex_class(Opportunity)
    end

    def reindex_class(klass)
      ENV['CLASS'] = klass.name
      ENV['INDEX'] = new_index = klass.tire.index.name.dup << '_' << Rails.env.to_s << '_' << Time.now.strftime('%Y%m%d%H%M%S')

      if Rails.env.production? || Rails.env.staging?
        Rake::Task["tire:import"].invoke
      else
        klass.rebuild_index(new_index)
      end

      puts '[IMPORT] about to swap index'
      if a = Tire::Alias.find(klass.tire.index.name)
        puts "[IMPORT] aliases found: #{Tire::Alias.find(klass.tire.index.name).indices.to_ary.join(',')}. deleting."
        old_indices = Tire::Alias.find(klass.tire.index.name).indices
        old_indices.each do |index|
          a.indices.delete index
        end
        a.indices.add new_index
        a.save
        old_indices.each do |index|
          puts "[IMPORT] deleting index: #{index}"
          i = Tire::Index.new(index)
          i.delete if i.exists?
        end
      else
        puts "[IMPORT] no aliases found. deleting index. creating new one and setting up alias."
        klass.tire.index.delete
        a = Tire::Alias.new
        a.name(klass.tire.index.name)
        a.index(new_index)
        a.save
        puts "Saved alias #{klass.tire.index.name} pointing to #{new_index}"
      end

      puts "[IMPORT] done. Index: '#{new_index}' created."
    end
  end

  desc 'Tap. Tap. Is this thing on?'
  task :ping do
    system('curl -X GET "http://cw-proxy.herokuapp.com/production/protip/_search?from=0&page=1&per_page=16&size=16&pretty=true" -d \'{"query":{"query_string":{"query":"flagged:false ","default_operator":"AND"}},"sort":[[{"popular_score":"desc"}]],"size":16,"from":0}\'')
  end

  # PRODUCTION: RUNS DAILY
  desc 'Sychronize index of the protips between the database and ElasticSearch'
  task :sync => :environment do
    number_of_protips_in_index = Protip.tire.search { query { all } }.total
    number_of_protips_in_database = Protip.count

    if number_of_protips_in_index != number_of_protips_in_database
      protips_in_index = Protip.tire.search do
        size number_of_protips_in_index
        query { all }
      end.map { |protip| protip.id.to_i }

      protips_in_database = Protip.select(:id).map(&:id)

      #now that we know the sets in db and index, calculate the missing records
      nonexistent_protips = (protips_in_index - protips_in_database)
      unindexed_protips = (protips_in_database - protips_in_index)

      nonexistent_protips.each do |nonexistent_protip_id|
        Protip.index.remove({'_id' => nonexistent_protip_id, '_type' => 'protip'})
      end

      unindexed_protips.each do |unindexed_protip_id|
        IndexProtip.perform_async(unindexed_protip_id)
      end

      puts "removed #{nonexistent_protips.count} protips and added #{unindexed_protips.count} protips"
    end
  end

  desc 'Index the protips for a given Network'
  task :index_network => :environment do
    unless ENV['NETWORK'].blank?
      network = Network.find_by_slug(ENV['NETWORK'])
      network.protips.select(:id).each do |protip|
        enqueue(ProcessProtipJob, :recalculate_score, protip.id)
      end
    end
  end
end
