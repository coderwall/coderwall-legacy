include_recipe 'apt'

apt_package 'libffi-dev' do
  action :nothing
end.run_action(:install)