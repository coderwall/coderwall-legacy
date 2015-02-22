if defined?(ChefSpec)
  def set_git_config(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:git_config, :set, resource_name)
  end
end
