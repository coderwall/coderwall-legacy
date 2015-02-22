Mysql chef gem Cookbook
=======================

Making custom Chef resource mysql chef gem.

Scope
-----
This cookbook is concerned with mysql chef gem.
This cookbook does not do everything.

Requirements
------------
* Chef 11 or higher
* Ruby 1.9 (preferably from the Chef full-stack installer)

Resources / Providers
---------------------
### mysql_chef_gem

The `mysql_chef_gem` resource configures things.

### Example

    mysql_chef_gem 'default' do
      action :install
    end

Recipes
-------
### mysql_chef_gem::default

This recipe calls a `mysql_chef_gem` resource, passing parameters
from node attributes.

Usage
-----
The  `crossplat_thing` resource is designed to do things.

### run_list

Include `'recipe[mysql_chef_gem::default]'`

### Wrapper cookbook

    node.default['mysql_chef_gem']['an_attribute'] = 'Chef'

    include_recipe 'mysql_chef_gem::default'

    ruby_block 'wat' do
      notifies :restart, mysql_chef_gem[wat]'
    end

### Used directly in a recipe

    mysql_chef_gem 'wat' do
      action :create
    end

    ruby_block 'wat' do
      notifies :restart, mysql_chef_gem[wat]'
    end

Attributes
----------

    default['mysql_chef_gem']['resource_name'] = 'default'
    default['mysql_chef_gem']['an_attribute'] = 'chef'

License & Authors
-----------------
- Author:: Sean OMeara (<someara@opscode.com>)

```text
Copyright:: 2009-2014 Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
