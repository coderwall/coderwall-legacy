require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlClient
      class FreeBSD < Chef::Provider::MysqlClient
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'freebsd pattern' do
            package 'mysql55-client' do
              action :install
            end
          end
        end

        action :delete do
          converge_by 'freebsd pattern' do
            package 'mysql55-client' do
              action :remove
            end
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :freebsd, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::FreeBSD
