name              "postgresql"
maintainer        "Heavy Water Operations, LLC"
maintainer_email  "support@hw-ops.com"
license           "Apache 2.0"
description       "Installs and configures postgresql for clients or servers"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "3.4.16"
recipe            "postgresql", "Includes postgresql::client"
recipe            "postgresql::ruby", "Installs pg gem for Ruby bindings"
recipe            "postgresql::client", "Installs postgresql client package(s)"
recipe            "postgresql::server", "Installs postgresql server packages, templates"
recipe            "postgresql::server_redhat", "Installs postgresql server packages, redhat family style"
recipe            "postgresql::server_debian", "Installs postgresql server packages, debian family style"


supports "ubuntu", "< 14.10"

%w{debian fedora suse amazon}.each do |os|
  supports os
end

%w{redhat centos scientific oracle}.each do |el|
  supports el, "~> 6.0"
end

depends "apt", ">= 1.9.0"
depends "build-essential"
depends "openssl"
