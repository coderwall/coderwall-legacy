class Chef
  class Provider
    class MysqlChefGem < Chef::Provider::LWRPBase
      use_inline_resources if defined?(use_inline_resources)

      def whyrun_supported?
        true
      end

      def action_install
        converge_by 'install mysql chef_gem and dependencies' do
          recipe_eval do
            run_context.include_recipe 'build-essential::default'
          end

          recipe_eval do
            run_context.include_recipe 'mysql::client'
          end

          chef_gem 'mysql' do
            action :install
          end
        end
      end

      def action_remove
        chef_gem 'mysql' do
          action :remove
        end
      end
    end
  end
end
