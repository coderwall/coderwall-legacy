#
# Author:: Jamie Winsor (<jamie@vialstudios.com>)
# Cookbook Name:: git
# Attributes:: default
#
# Copyright 2008-2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

case node['platform_family']
when 'windows'
  default['git']['version'] = '1.9.5-preview20141217'
  default['git']['url'] = "https://github.com/msysgit/msysgit/releases/download/Git-#{node['git']['version']}/Git-#{node['git']['version']}.exe"
  default['git']['checksum'] = 'd7e78da2251a35acd14a932280689c57ff9499a474a448ae86e6c43b882692dd'
  default['git']['display_name'] = "Git version #{ node['git']['version'] }"
when 'mac_os_x'
  default['git']['osx_dmg']['app_name']    = 'git-1.9.5-intel-universal-snow-leopard'
  default['git']['osx_dmg']['volumes_dir'] = 'Git 1.9.5 Snow Leopard Intel Universal'
  default['git']['osx_dmg']['package_id']  = 'GitOSX.Installer.git195.git.pkg'
  default['git']['osx_dmg']['url']         = 'http://sourceforge.net/projects/git-osx-installer/files/git-1.9.5-intel-universal-snow-leopard.dmg/download'
  default['git']['osx_dmg']['checksum']    = '61b8a9fda547725f6f0996c3d39a62ec3334e4c28a458574bc2aea356ebe94a1'
else
  default['git']['prefix'] = '/usr/local'
  default['git']['version'] = '1.9.5'
  default['git']['url'] = "https://nodeload.github.com/git/git/tar.gz/v#{node['git']['version']}"
  default['git']['checksum'] = '0f30984828d573da01d9f8e78210d5f4c56da1697fd6d278bad4cfa4c22ba271'
end

default['git']['server']['base_path'] = '/srv/git'
default['git']['server']['export_all'] = 'true'
