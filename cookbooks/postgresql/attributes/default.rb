#
# Cookbook Name:: postgresql
# Attributes:: postgresql
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['postgresql']['enable_pgdg_apt'] = false
default['postgresql']['server']['config_change_notify'] = :restart
default['postgresql']['assign_postgres_password'] = true

# Establish default database name
default['postgresql']['database_name'] = 'template1'

case node['platform']
when "debian"

  case
  when node['platform_version'].to_f < 6.0 # All 5.X
    default['postgresql']['version'] = "8.3"
  when node['platform_version'].to_f < 7.0 # All 6.X
    default['postgresql']['version'] = "8.4"
  else
    default['postgresql']['version'] = "9.1"
  end

when "ubuntu"

  case
  when node['platform_version'].to_f <= 9.04
    default['postgresql']['version'] = "8.3"
  when node['platform_version'].to_f <= 11.04
    default['postgresql']['version'] = "8.4"
  when node['platform_version'].to_f <= 13.10
    default['postgresql']['version'] = "9.1"
  else
    default['postgresql']['version'] = "9.3"
  end

when "fedora"

  if node['platform_version'].to_f <= 12
    default['postgresql']['version'] = "8.3"
  else
    default['postgresql']['version'] = "8.4"
  end

when "amazon"

  if node['platform_version'].to_f >= 2012.03
    default['postgresql']['version'] = "9.0"
  else
    default['postgresql']['version'] = "8.4"
  end

when "redhat", "centos", "scientific", "oracle"

  default['postgresql']['version'] = "8.4"

when "suse"

  if node['platform_version'].to_f <= 11.1
    default['postgresql']['version'] = "8.3"
  else
    default['postgresql']['version'] = "9.1"
  end

  default['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['server']['service_name'] = "postgresql"

else
  default['postgresql']['version'] = "8.4"
end

# These defaults have disparity between which postgresql configuration
# settings are used because they were extracted from the original
# configuration files that are now removed in favor of dynamic
# generation.
#
# While the configuration ends up being the same as the default
# in previous versions of the cookbook, the content of the rendered
# template will change, and this will result in service notification
# if you upgrade the cookbook on existing systems.
#
# The ssl config attribute is generated in the recipe to avoid awkward
# merge/precedence order during the Chef run.
case node['platform_family']
when 'debian'
  default['postgresql']['config']['listen_addresses'] = 'localhost'
  default['postgresql']['config']['port'] = 5432
  default['postgresql']['config']['max_connections'] = 100
  default['postgresql']['config']['shared_buffers'] = '24MB'
  default['postgresql']['config']['log_line_prefix'] = '%t '
  default['postgresql']['config']['datestyle'] = 'iso, mdy'
  default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
  default['postgresql']['config']['ssl'] = true
when 'rhel', 'fedora', 'suse'
  default['postgresql']['config']['data_directory'] = node['postgresql']['dir']
  default['postgresql']['config']['listen_addresses'] = 'localhost'
  default['postgresql']['config']['port'] = 5432
  default['postgresql']['config']['max_connections'] = 100
  default['postgresql']['config']['shared_buffers'] = '32MB'
  default['postgresql']['config']['logging_collector'] = true
  default['postgresql']['config']['log_directory'] = 'pg_log'
  default['postgresql']['config']['log_filename'] = 'postgresql-%a.log'
  default['postgresql']['config']['log_truncate_on_rotation'] = true
  default['postgresql']['config']['log_rotation_age'] = '1d'
  default['postgresql']['config']['log_rotation_size'] = 0
  default['postgresql']['config']['datestyle'] = 'iso, mdy'
  default['postgresql']['config']['lc_messages'] = 'en_US.UTF-8'
  default['postgresql']['config']['lc_monetary'] = 'en_US.UTF-8'
  default['postgresql']['config']['lc_numeric'] = 'en_US.UTF-8'
  default['postgresql']['config']['lc_time'] = 'en_US.UTF-8'
  default['postgresql']['config']['default_text_search_config'] = 'pg_catalog.english'
end

default['postgresql']['pg_hba'] = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'ident'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '::1/128', :method => 'md5'}
]

default['postgresql']['password'] = Hash.new

case node['platform_family']
when 'debian'
  default['postgresql']['pgdg']['release_apt_codename'] = node['lsb']['codename']
end

default['postgresql']['enable_pgdg_yum'] = false

default['postgresql']['initdb_locale'] = nil

# The PostgreSQL RPM Building Project built repository RPMs for easy
# access to the PGDG yum repositories. Links to RPMs for installation
# on the supported version/platform combinations are listed at
# http://yum.postgresql.org/repopackages.php, and the links for
# PostgreSQL 8.4, 9.0, 9.1, 9.2 and 9.3 are captured below.
#
# The correct RPM for installing /etc/yum.repos.d is based on:
# * the attribute configuring the desired Postgres Software:
#   node['postgresql']['version']        e.g., "9.1"
# * the chef ohai description of the target Operating System:
#   node['platform']                     e.g., "centos"
#   node['platform_version']             e.g., "5.7", truncated as "5"
#   node['kernel']['machine']            e.g., "i386" or "x86_64"
default['postgresql']['pgdg']['repo_rpm_url'] = {
  "9.3" => {
    "amazon" => {
      "2014" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/pgdg-redhat93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm"
      },
      "2013" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/pgdg-redhat93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm"
      }
    },
    "centos" => {
      "7" => {
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-1.noarch.rpm"
      },
      "6" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/pgdg-centos93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-5-i386/pgdg-centos93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/pgdg-centos93-9.3-1.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/pgdg-redhat93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-5-i386/pgdg-redhat93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/pgdg-redhat93-9.3-1.noarch.rpm"
      }
    },
    "oracle" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/pgdg-redhat93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-redhat93-9.3-1.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-5-i386/pgdg-redhat93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/pgdg-redhat93-9.3-1.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-6-i386/pgdg-sl93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-sl93-9.3-1.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.3/redhat/rhel-5-i386/pgdg-sl93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/redhat/rhel-5-x86_64/pgdg-sl93-9.3-1.noarch.rpm"
      }
    },
    "fedora" => {
      "20" => {
        "x86_64" => "http://yum.postgresql.org/9.3/fedora/fedora-20-x86_64/pgdg-fedora93-9.3-1.noarch.rpm"
      },
      "19" => {
        "x86_64" => "http://yum.postgresql.org/9.3/fedora/fedora-19-x86_64/pgdg-fedora93-9.3-1.noarch.rpm"
      },
      "18" => {
        "i386" => "http://yum.postgresql.org/9.3/fedora/fedora-18-i386/pgdg-fedora93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/fedora/fedora-18-x86_64/pgdg-fedora93-9.3-1.noarch.rpm"
      },
      "17" => {
        "i386" => "http://yum.postgresql.org/9.3/fedora/fedora-17-i386/pgdg-fedora93-9.3-1.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.3/fedora/fedora-17-x86_64/pgdg-fedora93-9.3-1.noarch.rpm"
      }
    }
  },
  "9.2" => {
    "centos" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-centos92-9.2-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-centos92-9.2-6.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-centos92-9.2-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-centos92-9.2-6.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-redhat92-9.2-7.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-redhat92-9.2-7.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-redhat92-9.2-7.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-redhat92-9.2-7.noarch.rpm"
      }
    },
    "oracle" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-redhat92-9.2-7.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-redhat92-9.2-7.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-redhat92-9.2-7.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-redhat92-9.2-7.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-6-i386/pgdg-sl92-9.2-8.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-6-x86_64/pgdg-sl92-9.2-8.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.2/redhat/rhel-5-i386/pgdg-sl92-9.2-8.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/redhat/rhel-5-x86_64/pgdg-sl92-9.2-8.noarch.rpm"
      }
    },
    "fedora" => {
      "19" => {
        "i386" => "http://yum.postgresql.org/9.2/fedora/fedora-19-i386/pgdg-fedora92-9.2-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/fedora/fedora-19-x86_64/pgdg-fedora92-9.2-6.noarch.rpm"
      },
      "18" => {
        "i386" => "http://yum.postgresql.org/9.2/fedora/fedora-18-i386/pgdg-fedora92-9.2-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/fedora/fedora-18-x86_64/pgdg-fedora92-9.2-6.noarch.rpm"
      },
      "17" => {
        "i386" => "http://yum.postgresql.org/9.2/fedora/fedora-17-i386/pgdg-fedora92-9.2-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/fedora/fedora-17-x86_64/pgdg-fedora92-9.2-5.noarch.rpm"
      },
      "16" => {
        "i386" => "http://yum.postgresql.org/9.2/fedora/fedora-16-i386/pgdg-fedora92-9.2-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.2/fedora/fedora-16-x86_64/pgdg-fedora92-9.2-5.noarch.rpm"
      }
    }
  },
  "9.1" => {
    "centos" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-centos91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-centos91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-4-i386/pgdg-centos91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-4-x86_64/pgdg-centos91-9.1-4.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-redhat91-9.1-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-redhat91-9.1-5.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-redhat91-9.1-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-redhat91-9.1-5.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-4-i386/pgdg-redhat-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-4-x86_64/pgdg-redhat-9.1-4.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-6-i386/pgdg-sl91-9.1-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-sl91-9.1-6.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.1/redhat/rhel-5-i386/pgdg-sl91-9.1-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/redhat/rhel-5-x86_64/pgdg-sl91-9.1-6.noarch.rpm"
      }
    },
    "fedora" => {
      "16" => {
        "i386" => "http://yum.postgresql.org/9.1/fedora/fedora-16-i386/pgdg-fedora91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/fedora/fedora-16-x86_64/pgdg-fedora91-9.1-4.noarch.rpm"
      },
      "15" => {
        "i386" => "http://yum.postgresql.org/9.1/fedora/fedora-15-i386/pgdg-fedora91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/fedora/fedora-15-x86_64/pgdg-fedora91-9.1-4.noarch.rpm"
      },
      "14" => {
        "i386" => "http://yum.postgresql.org/9.1/fedora/fedora-14-i386/pgdg-fedora91-9.1-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.1/fedora/fedora-14-x86_64/pgdg-fedora-9.1-2.noarch.rpm"
      }
    }
  },
  "9.0" => {
    "centos" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-6-i386/pgdg-centos90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-centos90-9.0-5.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-5-i386/pgdg-centos90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-centos90-9.0-5.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-4-i386/pgdg-centos90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-4-x86_64/pgdg-centos90-9.0-5.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-6-i386/pgdg-redhat90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-redhat90-9.0-5.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-5-i386/pgdg-redhat90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-redhat90-9.0-5.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-4-i386/pgdg-redhat90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-4-x86_64/pgdg-redhat90-9.0-5.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-6-i386/pgdg-sl90-9.0-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-6-x86_64/pgdg-sl90-9.0-6.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/9.0/redhat/rhel-5-i386/pgdg-sl90-9.0-6.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/redhat/rhel-5-x86_64/pgdg-sl90-9.0-6.noarch.rpm"
      }
    },
    "fedora" => {
      "15" => {
        "i386" => "http://yum.postgresql.org/9.0/fedora/fedora-15-i386/pgdg-fedora90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/fedora/fedora-15-x86_64/pgdg-fedora90-9.0-5.noarch.rpm"
      },
      "14" => {
        "i386" => "http://yum.postgresql.org/9.0/fedora/fedora-14-i386/pgdg-fedora90-9.0-5.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/9.0/fedora/fedora-14-x86_64/pgdg-fedora90-9.0-5.noarch.rpm"
      }
    }
  },
  "8.4" => {
    "centos" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-6-i386/pgdg-centos-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-6-x86_64/pgdg-centos-8.4-3.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-5-i386/pgdg-centos-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-5-x86_64/pgdg-centos-8.4-3.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-4-i386/pgdg-centos-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-4-x86_64/pgdg-centos-8.4-3.noarch.rpm"
      }
    },
    "redhat" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-6-i386/pgdg-redhat-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-6-x86_64/pgdg-redhat-8.4-3.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-5-i386/pgdg-redhat-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-5-x86_64/pgdg-redhat-8.4-3.noarch.rpm"
      },
      "4" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-4-i386/pgdg-redhat-8.4-3.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-4-x86_64/pgdg-redhat-8.4-3.noarch.rpm"
      }
    },
    "scientific" => {
      "6" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-6-i386/pgdg-sl84-8.4-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-6-x86_64/pgdg-sl84-8.4-4.noarch.rpm"
      },
      "5" => {
        "i386" => "http://yum.postgresql.org/8.4/redhat/rhel-5-i386/pgdg-sl-8.4-4.noarch.rpm",
        "x86_64" => "http://yum.postgresql.org/8.4/redhat/rhel-5-x86_64/pgdg-sl-8.4-4.noarch.rpm"
      }
    },
    "fedora" => {
      "14" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-14-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-14-x86_64/"
      },
      "13" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-13-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-13-x86_64/"
      },
      "12" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-12-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-12-x86_64/"
      },
      "8" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-8-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-8-x86_64/"
      },
      "7" => {
        "i386" => "http://yum.postgresql.org/8.4/fedora/fedora-7-i386/",
        "x86_64" => "http://yum.postgresql.org/8.4/fedora/fedora-7-x86_64/"
      }
    }
  },
};

