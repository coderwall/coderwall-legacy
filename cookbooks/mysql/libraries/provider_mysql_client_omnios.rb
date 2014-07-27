require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlClient
      class Omnios < Chef::Provider::MysqlClient
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'omnios pattern' do
            package 'database/mysql-55' do
              action :install
            end

            package 'database/mysql-55/library' do
              action :install
            end
          end
        end

        action :delete do
          converge_by 'omnios pattern' do
            package 'database/mysql-55' do
              action :remove
            end

            package 'database/mysql-55/library' do
              action :remove
            end
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :omnios, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Omnios
