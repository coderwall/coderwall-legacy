require 'chef/provider/lwrp_base'
require 'shellwords'

class Chef
  class Provider
    class MysqlService
      class Fedora < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        action :create do
          converge_by 'fedora pattern' do

            prefix_dir = '/usr'
            include_dir = '/etc/my.cnf.d'
            lc_messages_dir = nil
            run_dir = '/var/run/mysqld'
            pid_file = '/var/run/mysqld/mysqld.pid'
            socket_file = '/var/lib/mysql/mysql.sock'
            package_name = 'community-mysql-server'

            package package_name do
              action :install
            end

            directory include_dir do
              owner 'mysql'
              group 'mysql'
              mode '0750'
              action :create
              recursive true
            end

            directory run_dir do
              owner 'mysql'
              group 'mysql'
              mode '0755'
              action :create
              recursive true
            end

            directory new_resource.data_dir do
              owner 'mysql'
              group 'mysql'
              mode '0755'
              action :create
              recursive true
            end

            service 'mysqld' do
              supports :restart => true
              action [:start, :enable]
            end

            execute 'wait for mysql' do
              command "until [ -S #{socket_file} ] ; do sleep 1 ; done"
              timeout 10
              action :run
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
              cmd = "#{prefix_dir}/bin/mysql"
              cmd << ' -u root '
              cmd << "#{pass_string} < /etc/mysql_grants.sql"
              command cmd
              action :nothing
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
                :include_dir => include_dir,
                :lc_messages_dir => lc_messages_dir,
                :pid_file => pid_file,
                :port => new_resource.port,
                :prefix_dir => prefix_dir,
                :socket_file => socket_file
                )
              action :create
              notifies :run, 'bash[move mysql data to datadir]'
              notifies :restart, 'service[mysqld]'
            end

            bash 'move mysql data to datadir' do
              user 'root'
              code <<-EOH
              service mysqld stop \
              && for i in `ls /var/lib/mysql | grep -v mysql.sock` ; do mv /var/lib/mysql/$i #{new_resource.data_dir} ; done
              EOH
              action :nothing
              creates "#{new_resource.data_dir}/ibdata1"
              creates "#{new_resource.data_dir}/ib_logfile0"
              creates "#{new_resource.data_dir}/ib_logfile1"
            end

            execute 'assign-root-password' do
              cmd = "#{prefix_dir}/bin/mysqladmin"
              cmd << ' -u root password '
              cmd << Shellwords.escape(new_resource.server_root_password)
              command cmd
              action :run
              only_if "#{prefix_dir}/bin/mysql -u root -e 'show databases;'"
            end
          end
        end

        action :restart do
          converge_by 'fedora pattern' do
            service 'mysqld' do
              supports :restart => true
              action :restart
            end
          end
        end

        action :reload do
          converge_by 'fedora pattern' do
            service 'mysqld' do
              action :reload
            end
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :fedora, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::Fedora
