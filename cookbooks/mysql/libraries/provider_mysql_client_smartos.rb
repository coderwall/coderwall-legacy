require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlClient
      class Smartos < Chef::Provider::MysqlClient
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'smartos pattern' do
            package 'mysql-client' do
              action :install
            end
          end
        end

        action :delete do
          converge_by 'smartos pattern' do
            package 'mysql-client' do
              action :remove
            end
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :smartos, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Smartos
