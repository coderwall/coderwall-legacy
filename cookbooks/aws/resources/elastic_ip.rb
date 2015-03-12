actions :associate, :disassociate, :allocate

state_attrs :aws_access_key,
            :ip,
            :timeout

attribute :aws_access_key,        kind_of: String
attribute :aws_secret_access_key, kind_of: String
attribute :ip,                    kind_of: String, name_attribute: true
attribute :timeout,               default: 3 * 60 # 3 mins, nil or 0 for no timeout

def initialize(*args)
  super
  @action = :associate
end
