# List of environments and their heroku git remotes
ENVIRONMENTS = {
    staging: 'coderwall-staging',
    production: 'coderwall-production'
}
namespace :deploy do
  ENVIRONMENTS.keys.each do |env|
    desc "Deploy to #{env}"
    task env do
      Rake::Task['deploy:after_deploy'].invoke
    end
  end

  task :after_deploy do |t, args|
    Rake::Task['humans'].invoke
  end
end