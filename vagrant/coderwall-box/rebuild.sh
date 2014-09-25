cd ~/assemblymade/coderwall
vagrant halt
vagrant destroy -f
vagrant box remove coderwall
cd vagrant/coderwall-box
rm -rf output-virtualbox-iso
rm -rf packer_virtualbox-iso_virtualbox.box
rm -rf packer_cache
packer validate template.json
packer build template.json
vagrant box add coderwall ./packer_virtualbox-iso_virtualbox.box
