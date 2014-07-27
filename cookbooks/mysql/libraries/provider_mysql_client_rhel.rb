require 'chef/provider/lwrp_base'

class Chef
  class Provider
    class MysqlClient
      class Rhel < Chef::Provider::MysqlClient
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'rhel pattern' do
            %w(mysql mysql-devel).each do |p|
              package p do
                action :install
              end
            end
          end
        end

        action :delete do
          converge_by 'rhel pattern' do
            %w(mysql mysql-devel).each do |p|
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

Chef::Platform.set :platform => :rhel, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :amazon, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :redhat, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :centos, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :oracle, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
Chef::Platform.set :platform => :scientific, :resource => :mysql_client, :provider => Chef::Provider::MysqlClient::Rhel
