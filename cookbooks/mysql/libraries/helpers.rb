module Opscode
  module Mysql
    module Helpers
      def default_version_for(platform, platform_family, platform_version)
        keyname = keyname_for(platform, platform_family, platform_version)
        PlatformInfo.mysql_info[platform_family][keyname]['default_version']
      rescue NoMethodError
        nil
      end

      def package_name_for(platform, platform_family, platform_version, version)
        keyname = keyname_for(platform, platform_family, platform_version)
        PlatformInfo.mysql_info[platform_family][keyname][version]['package_name']
      rescue NoMethodError
        nil
      end

      def service_name_for(platform, platform_family, platform_version, version)
        keyname = keyname_for(platform, platform_family, platform_version)
        PlatformInfo.mysql_info[platform_family][keyname][version]['service_name']
      rescue NoMethodError
        nil
      end

      def default_data_dir_for(platform_family)
        PlatformInfo.mysql_info[platform_family]['default_data_dir']
      rescue NoMethodError
        nil
      end

      def keyname_for(platform, platform_family, platform_version)
        case
        when platform_family == 'rhel'
          platform == 'amazon' ? platform_version : platform_version.to_i.to_s
        when platform_family == 'suse'
          platform_version
        when platform_family == 'fedora'
          platform_version
        when platform_family == 'debian'
          if platform == 'ubuntu'
            platform_version
          elsif platform_version =~ /sid$/
            platform_version
          else
            platform_version.to_i.to_s
          end
        when platform_family == 'smartos'
          platform_version
        when platform_family == 'omnios'
          platform_version
        when platform_family == 'freebsd'
          platform_version.to_i.to_s
        end
      rescue NoMethodError
        nil
      end
    end

    class PlatformInfo
      def self.mysql_info
        @mysql_info ||= {
          'rhel' => {
            'default_data_dir' => '/var/lib/mysql',
            '5' => {
              'default_version' => '5.0',
              '5.0' => {
                'package_name' => 'mysql-server',
                'service_name' => 'mysqld'
              },
              '5.1' => {
                'package_name' => 'mysql51-mysql-server',
                'service_name' => 'mysql51-mysqld'
              },
              '5.5' => {
                'package_name' => 'mysql55-mysql-server',
                'service_name' => 'mysql55-mysqld'
              }
            },
            '6' => {
              'default_version' => '5.1',
              '5.1' => {
                'package_name' => 'mysql-server',
                'service_name' => 'mysqld'
              },
              '5.5' => {
                'package_name' => 'mysql-community-server',
                'service_name' => 'mysqld'
              },
              '5.6' => {
                'package_name' => 'mysql-community-server',
                'service_name' => 'mysqld'
              }
            },
            '7' => {
              'default_version' => '5.5',
              '5.1' => {
                'package_name' => 'mysql51-server',
                'service_name' => 'mysqld'
              },
              '5.5' => {
                'package_name' => 'mysql55-server',
                'service_name' => 'mysqld'
              }
            },
            '2013.03' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql-server',
                'service_name' => 'mysqld'
              }
            },
            '2013.09' => {
              'default_version' => '5.1',
              '5.1' => {
                'package_name' => 'mysql-community-server',
                'service_name' => 'mysqld'
              },
              '5.5' => {
                'package_name' => 'mysql-community-server',
                'service_name' => 'mysqld'
              },
              '5.6' => {
                'package_name' => 'mysql-community-server',
                'service_name' => 'mysqld'
              }
            },
            '2014.03' => {
              'default_version' => '5.5',
              '5.1' => {
                'package_name' => 'mysql51-server',
                'service_name' => 'mysqld'
              },
              '5.5' => {
                'package_name' => 'mysql-community-server',
                'service_name' => 'mysqld'
              },
              '5.6' => {
                'package_name' => 'mysql-community-server',
                'service_name' => 'mysqld'
              }
            }
          },
          'fedora' => {
            'default_data_dir' => '/var/lib/mysql',
            '19' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'community-mysql-server',
                'service_name' => 'mysqld'
              }
            },
            '20' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'community-mysql-server',
                'service_name' => 'mysqld'
              }
            }
          },
          'suse' => {
            'default_data_dir' => '/var/lib/mysql',
            '11.3' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql',
                'service_name' => 'mysql'
              }
            }
          },
          'debian' => {
            'default_data_dir' => '/var/lib/mysql',
            '7' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql-server-5.5',
                'service_name' => 'mysqld'
              }
            },
            'jessie/sid' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql-server-5.5',
                'service_name' => 'mysqld'
              }
            },
            '10.04' => {
              'default_version' => '5.1',
              '5.1' => {
                'package_name' => 'mysql-server-5.1',
                'service_name' => 'mysqld'
              }
            },
            '12.04' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql-server-5.5',
                'service_name' => 'mysqld'
              }
            },
            '13.04' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql-server-5.5',
                'service_name' => 'mysqld'
              }
            },
            '13.10' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql-server-5.5',
                'service_name' => 'mysqld'
              }
            },
            '14.04' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql-server-5.5',
                'service_name' => 'mysql'
              },
              '5.6' => {
                'package_name' => 'mysql-server-5.6',
                'service_name' => 'mysql'
              }
            }
          },
          'smartos' => {
            'default_data_dir' => '/opt/local/lib/mysql',
            # Do this or now, until Ohai correctly detects a
            # smartmachine vs global zone (base64 13.4.0) from /etc/product
            '5.11' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql-server',
                'service_name' => 'mysql'
              },
              '5.6' => {
                'package_name' => 'mysql-server',
                'service_name' => 'mysql'
              }
            }
          },
          'omnios' => {
            'default_data_dir' => '/var/lib/mysql',
            '151006' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'database/mysql-55',
                'service_name' => 'mysql'
              },
              '5.6' => {
                'package_name' => 'database/mysql-56',
                'service_name' => 'mysql'
              }
            }
          },
          'freebsd' => {
            'default_data_dir' => '/var/db/mysql',
            '9' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql55-server',
                'service_name' => 'mysql-server'
              }
            },
            '10' => {
              'default_version' => '5.5',
              '5.5' => {
                'package_name' => 'mysql55-server',
                'service_name' => 'mysql-server'
              }
            }
          }
        }
      end
    end
  end
end
