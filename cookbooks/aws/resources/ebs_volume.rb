actions :create, :attach, :detach, :snapshot, :prune

state_attrs :availability_zone,
            :aws_access_key,
            :description,
            :device,
            :most_recent_snapshot,
            :piops,
            :size,
            :snapshot_id,
            :snapshots_to_keep,
            :timeout,
            :volume_id,
            :volume_type

attribute :aws_access_key,        kind_of: String
attribute :aws_secret_access_key, kind_of: String
attribute :size,                  kind_of: Integer
attribute :snapshot_id,           kind_of: String
attribute :most_recent_snapshot,  kind_of: [TrueClass, FalseClass], default: false
attribute :availability_zone,     kind_of: String
attribute :device,                kind_of: String
attribute :volume_id,             kind_of: String
attribute :description,           kind_of: String
attribute :timeout,               default: 3 * 60 # 3 mins, nil or 0 for no timeout
attribute :snapshots_to_keep,     default: 2
attribute :volume_type,           kind_of: String, default: 'standard'
attribute :piops,                 kind_of: Integer, default: 0

def initialize(*args)
  super
  @action = :create
end
