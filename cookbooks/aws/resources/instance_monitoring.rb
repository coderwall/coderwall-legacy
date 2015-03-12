def initialize(*args)
  super
  @action = :enable
end

actions :enable, :disable

state_attrs :aws_access_key

attribute :aws_access_key, kind_of: String
attribute :aws_secret_access_key, kind_of: String
