require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlClient
      class Suse < Chef::Provider::MysqlClient
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'suse pattern' do
            %w(mysql-client).each do |p|
              package p do
                action :install
              end
            end
          end
        end

        action :delete do
          converge_by 'suse pattern' do
            %w(mysql-client).each do |p|
              package p do
                action :remove
              end
            end
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :suse, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Suse
