#
# Author:: Douglas Thrift (<douglas.thrift@rightscale.com>)
# Cookbook Name:: database
# Library:: matchers
#
# Copyright 2014, Chef Software, Inc.
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

if defined?(ChefSpec)
  # database
  #
  def create_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database, :create, resource_name)
  end

  def drop_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database, :drop, resource_name)
  end

  def query_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database, :query, resource_name)
  end

  # database user
  #
  def create_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database_user, :create, resource_name)
  end

  def drop_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database_user, :drop, resource_name)
  end

  def grant_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:database_user, :grant, resource_name)
  end

  # mysql database
  #
  def create_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database, :create, resource_name)
  end

  def drop_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database, :drop, resource_name)
  end

  def query_mysql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database, :query, resource_name)
  end

  # mysql database user
  #
  def create_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database_user, :create, resource_name)
  end

  def drop_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database_user, :drop, resource_name)
  end

  def grant_mysql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_database_user, :grant, resource_name)
  end

  # postgresql database
  #
  def create_postgresql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database, :create, resource_name)
  end

  def drop_postgresql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database, :drop, resource_name)
  end

  def query_postgresql_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database, :query, resource_name)
  end

  # postgresql database schema
  #
  def create_postgresql_database_schema(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database_schema, :create, resource_name)
  end

  def drop_postgresql_database_schema(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database_schema, :drop, resource_name)
  end

  # postgresql database user
  #
  def create_postgresql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database_user, :create, resource_name)
  end

  def drop_postgresql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database_user, :drop, resource_name)
  end

  def grant_postgresql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database_user, :grant, resource_name)
  end

  def grant_schema_postgresql_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:postgresql_database_user, :grant_schema, resource_name)
  end

  # sql server database
  #
  def create_sql_server_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sql_server_database, :create, resource_name)
  end

  def drop_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sql_server_database, :drop, resource_name)
  end

  def query_database(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sql_server_database, :query, resource_name)
  end

  # sql server database user
  #
  def create_sql_server_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sql_server_database_user, :create, resource_name)
  end

  def drop_sql_server_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sql_server_database_user, :drop, resource_name)
  end

  def grant_sql_server_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sql_server_database_user, :grant, resource_name)
  end

  def alter_roles_sql_server_database_user(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sql_server_database_user, :alter_roles, resource_name)
  end
end
