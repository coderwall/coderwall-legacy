#
# Cookbook Name:: postgresql
# Recipe:: client
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'postgresql::config_version'

if platform_family?('debian') && node['postgresql']['version'].to_f > 9.3
  node.default['postgresql']['enable_pgdg_apt'] = true
end

if(node['postgresql']['enable_pgdg_apt']) and platform_family?('debian')
  include_recipe 'postgresql::apt_pgdg_postgresql'
end

if(node['postgresql']['enable_pgdg_yum']) and platform_family?('rhel')
  include_recipe 'postgresql::yum_pgdg_postgresql'
end

node['postgresql']['client']['packages'].each do |pg_pack|
  package pg_pack
end
