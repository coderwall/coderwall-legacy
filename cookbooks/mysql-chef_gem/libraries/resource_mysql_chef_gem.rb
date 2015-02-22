require 'chef/resource/lwrp_base'

class Chef
  class Resource
    class MysqlChefGem < Chef::Resource::LWRPBase
      self.resource_name = :mysql_chef_gem
      actions  :install, :remove
      default_action :install
    end
  end
end
