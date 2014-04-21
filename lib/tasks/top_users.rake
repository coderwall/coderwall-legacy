namespace :top_users do
  task :generate => :environment do
    GenerateTopUsersComposite.perform
  end

  namespace :generate do
    task :async => :environment do
      Resque.enqueue GenerateTopUsersComposite
    end
  end
end