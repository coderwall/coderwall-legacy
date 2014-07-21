namespace :top_users do
  task :generate => :environment do
    GenerateTopUsersCompositeJob.new.perform
  end

  namespace :generate do
    task :async => :environment do
      GenerateTopUsersCompositeJob.perform_async
    end
  end
end