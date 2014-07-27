require 'chef/resource/lwrp_base'
require_relative 'helpers'

extend Opscode::Mysql::Helpers
#
class Chef
  class Resource
    class MysqlService < Chef::Resource
      extend Opscode::Mysql::Helpers
      # Initialize resource
      def initialize(name = nil, run_context = nil)
        super
        @resource_name = :mysql_service
        @service_name = name

        @allowed_actions = [:create, :restart, :reload]
        @action = :create

        # set default values
        @version = default_version_for(
          node['platform'],
          node['platform_family'],
          node['platform_version']
          )

        @package_name = package_name_for(
          node['platform'],
          node['platform_family'],
          node['platform_version'],
          @version
          )

        @data_dir = default_data_dir_for(node['platform_family'])

        @port = '3306'
        @template_source = nil

        @allow_remote_root = false
        @remove_anonymous_users = true
        @remove_test_database = true
        @root_network_acl = []

        @server_root_password = 'ilikerandompasswords'
        @server_debian_password = 'gnuslashlinux4ev4r'
        @server_repl_password = nil
      end

      # attribute :service_name, kind_of: String
      def service_name(arg = nil)
        set_or_return(
          :service_name,
          arg,
          :kind_of => String
          )
      end

      # attribute :template_source, kind_of: String
      def template_source(arg = nil)
        set_or_return(
          :template_source,
          arg,
          :kind_of => String
          )
      end

      # attribute :port, kind_of: String
      def port(arg = nil)
        set_or_return(
          :port,
          arg,
          :kind_of => String,
          :callbacks => {
            'should be a valid non-system port' => lambda do |p|
              Chef::Resource::MysqlService.validate_port(p)
            end
          }
          )
      end

      # attribute :version, kind_of: String
      def version(arg = nil)
        # First, set the package_name to the appropriate value.
        package_name package_name_for(
          node['platform'],
          node['platform_family'],
          node['platform_version'],
          arg
          )

        # Then, validate and return the version number.
        set_or_return(
          :version,
          arg,
          :kind_of => String,
          :callbacks => {
            "is not supported for #{node['platform']}-#{node['platform_version']}" => lambda do |_mysql_version|
              true unless package_name_for(
                node['platform'],
                node['platform_family'],
                node['platform_version'],
                arg
                ).nil?
            end
          }
          )
      end

      # attribute :package_name, kind_of: String
      def package_name(arg = nil)
        set_or_return(
          :package_name,
          arg,
          :kind_of => String
          )
      end

      # attribute :data_dir, kind_of: String
      def data_dir(arg = nil)
        set_or_return(
          :data_dir,
          arg,
          :kind_of => String
          )
      end

      # attribute :allow_remote_root, kind_of: [TrueClass,FalseClass]
      def allow_remote_root(arg = nil)
        set_or_return(
          :allow_remote_root,
          arg,
          :kind_of => [TrueClass, FalseClass]
          )
      end

      # attribute :remove_anonymous_users, kind_of: [TrueClass,FalseClass]
      def remove_anonymous_users(arg = nil)
        set_or_return(
          :remove_anonymous_users,
          arg,
          :kind_of => [TrueClass, FalseClass]
          )
      end

      # attribute :remove_test_database, kind_of: [TrueClass,FalseClass]
      def remove_test_database(arg = nil)
        set_or_return(
          :remove_test_database,
          arg,
          :kind_of => [TrueClass, FalseClass]
          )
      end

      # attribute :root_network_acl, kind_of: Array
      def root_network_acl(arg = nil)
        set_or_return(
          :root_network_acl,
          arg,
          :kind_of => Array
          )
      end

      # attribute :server_root_password, kind_of: String
      def server_root_password(arg = nil)
        set_or_return(
          :server_root_password,
          arg,
          :kind_of => String
          )
      end

      # attribute :server_debian_password, kind_of: String
      def server_debian_password(arg = nil)
        set_or_return(
          :server_debian_password,
          arg,
          :kind_of => String
          )
      end

      # attribute :server_repl_password, kind_of: String
      def server_repl_password(arg = nil)
        set_or_return(
          :server_repl_password,
          arg,
          :kind_of => String
          )
      end

      def self.validate_port(port)
        port.to_i > 1024 && port.to_i < 65_535
      end
    end
  end
end
