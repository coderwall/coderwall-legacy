require 'chef/provider/lwrp_base'
require 'shellwords'

include Opscode::Mysql::Helpers

class Chef
  class Provider
    class MysqlService
      class FreeBSD < Chef::Provider::MysqlService
        use_inline_resources if defined?(use_inline_resources)

        def whyrun_supported?
          true
        end

        def rc_name
          service_name_for(
            node['platform'],
            node['platform_family'],
            node['platform_version'],
            new_resource.version
          )
        end

        action :create do
          converge_by 'freebsd pattern' do
            base_dir    = '/usr/local'
            prefix_dir  = '/usr/local'
            include_dir = '/usr/local/etc/mysql/conf.d'
            pid_file    = '/var/db/mysql/mysqld.pid'
            socket_file = '/tmp/mysqld.sock'
            my_cnf      = '/usr/local/etc/my.cnf'

            package new_resource.package_name do
              action :install
            end

            [include_dir, new_resource.data_dir].each do |dir|
              directory dir do
                owner 'mysql'
                group 'mysql'
                mode '0750'
                recursive true
                action :create
              end
            end

            template my_cnf do
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
                :base_dir    => base_dir,
                :include_dir => include_dir,
                :data_dir    => new_resource.data_dir,
                :pid_file    => pid_file,
                :socket_file => socket_file,
                :port        => new_resource.port,
                :lc_messages_dir => "#{base_dir}/share/mysql"
                )
              action :create
              notifies :restart, 'service[mysql]'
            end

            execute 'initialize mysql database' do
              cwd new_resource.data_dir
              command "#{prefix_dir}/bin/mysql_install_db --basedir=#{base_dir} --user=mysql"
              creates "#{new_resource.data_dir}/mysql/user.frm"
            end

            service 'mysql' do
              service_name rc_name
              supports :status => true, :restart => true, :reload => false
              action [:start, :enable]
            end

            execute 'wait for mysql' do
              command "while [ ! -S #{socket_file} ] ; do sleep 1 ; done"
              timeout 10
              action :run
            end

            execute 'assign-root-password' do
              cmd = "#{prefix_dir}/bin/mysqladmin"
              cmd << ' -u root password '
              cmd << Shellwords.escape(new_resource.server_root_password)
              command cmd
              action :run
              only_if "#{prefix_dir}/bin/mysql -u root -e 'show databases;'"
            end

            template '/etc/mysql_grants.sql' do
              cookbook 'mysql'
              source 'grants/grants.sql.erb'
              owner 'root'
              group node['root_group']
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
              retries 5
              retry_delay 2
              action :nothing
            end
          end
        end

        action :restart do
          converge_by 'freebsd pattern' do
            service 'mysql' do
              service_name rc_name
              supports :restart => true
              action :restart
            end
          end
        end

        action :reload do
          converge_by 'freebsd pattern' do
            service 'mysql' do
              service_name rc_name
              supports :reload => true
              action :reload
            end
          end
        end
      end
    end
  end
end

Chef::Platform.set :platform => :freebsd, :resource => :mysql_service, :provider => Chef::Provider::MysqlService::FreeBSD
