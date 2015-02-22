directory '/etc/chef/ohai/hints' do
  recursive true
  action :create
end.run_action(:create)

file '/etc/chef/ohai/hints/ec2.json' do
  content {}
  action :create
end.run_action(:create)

ohai 'reload' do
  action :reload
end.run_action(:reload)
