require 'chef/provider/lwrp_base'
require 'shellwords'
require_relative 'helpers'

extend Opscode::Mysql::Helpers

class Chef
  class Provider
    class MysqlService
      class Suse < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'suse pattern' do
            package 'mysql' do
              action :install
            end

            file '/etc/mysqlaccess.conf' do
              action :delete
            end

            file '/etc/mysql/default_plugins.cnf' do
              action :delete
            end

            file '/etc/mysql/secure_file_priv.conf' do
              action :delete
            end

            directory '/etc/mysql/conf.d' do
              owner 'mysql'
              group 'mysql'
              mode '0750'
              recursive true
              action :create
            end

            directory '/var/run/mysql' do
              owner 'mysql'
              group 'mysql'
              mode '0755'
              recursive true
              action :create
            end

            directory new_resource.data_dir do
              owner 'mysql'
              group 'mysql'
              mode '0755'
              recursive true
              action :create
            end

            template '/etc/my.cnf' do
              if new_resource.template_source.nil?
                source "#{new_resource.version}/my.cnf.erb"
                cookbook 'mysql'
              else
                source new_resource.template_source
              end
              owner 'mysql'
              group 'mysql'
              mode '0600'
              variables(
                :data_dir => new_resource.data_dir,
                :include_dir => '/etc/mysql/conf.d',
                :pid_file => '/var/run/mysql/mysql.pid',
                :port => new_resource.port,
                :socket_file => '/var/lib/mysql/mysql.sock'
                )
              action :create
              notifies :run, 'bash[move mysql data to datadir]'
              notifies :restart, 'service[mysql]'
            end

            execute 'initialize mysql database' do
              cwd new_resource.data_dir
              command '/usr/bin/mysql_install_db --user=mysql'
              creates "#{new_resource.data_dir}/mysql/user.frm"
              action :run
            end

            service 'mysql' do
              supports :restart => true, :reload => true
              action [:start, :enable]
              notifies :run, 'execute[wait for mysql]', :immediately
            end

            execute 'wait for mysql' do
              command 'until [ -S /var/lib/mysql/mysql.sock ] ; do sleep 1 ; done'
              timeout 10
              action :nothing
            end

            template '/etc/mysql_grants.sql' do
              cookbook 'mysql'
              source 'grants/grants.sql.erb'
              owner 'root'
              group 'root'
              mode '0600'
              variables(:config => new_resource)
              action :create
              notifies :run, 'execute[install-grants]'
            end

            if new_resource.server_root_password.empty?
              pass_string = ''
            else
              pass_string = '-p' + Shellwords.escape(new_resource.server_root_password)
            end

            execute 'install-grants' do
              cmd = '/usr/bin/mysql'
              cmd << ' -u root '
              cmd << "#{pass_string} < /etc/mysql_grants.sql"
              command cmd
              action :nothing
            end

            bash 'move mysql data to datadir' do
              user 'root'
              code <<-EOH
              service mysql stop \
              && for i in `ls /var/lib/mysql | grep -v mysql.sock` ; do mv /var/lib/mysql/$i #{new_resource.data_dir} ; done
              EOH
              action :nothing
              creates "#{new_resource.data_dir}/ibdata1"
              creates "#{new_resource.data_dir}/ib_logfile0"
              creates "#{new_resource.data_dir}/ib_logfile1"
            end

            execute 'assign-root-password' do
              cmd = '/usr/bin/mysqladmin'
              cmd << ' -u root password '
              cmd << Shellwords.escape(new_resource.server_root_password)
              command cmd
              action :run
              only_if "/usr/bin/mysql -u root -e 'show databases;'"
            end
          end
        end
      end

      action :restart do
        converge_by 'suse pattern' do
          service 'mysql' do
            supports :restart => true
            action :restart
          end
        end
      end

      action :reload do
        converge_by 'suse pattern' do
          service 'mysql' do
            supports :reload => true
            action :reload
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :suse, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Suse
