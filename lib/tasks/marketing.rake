namespace :marketing do
  namespace :emails do
    task :send => :environment do
      LifecycleMarketing.process!
    end


  end
end
