if defined?(ChefSpec)
  def install_mysql_chef_gem(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:mysql_chef_gem, :install, resource_name)
  end
end
