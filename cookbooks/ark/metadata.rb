name             'ark'
maintainer       'Bryan W. Berry'
maintainer_email 'bryan.berry@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures ark'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.9.0'

%w( debian ubuntu centos redhat fedora windows ).each do |os|
  supports os
end

recipe 'ark::default', 'Installs and configures ark'

depends 'windows'
depends '7-zip'