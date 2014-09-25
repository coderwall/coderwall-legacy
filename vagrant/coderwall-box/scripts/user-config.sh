sudo su - vagrant <<-'EOF'
  cd ~/web
  rvm requirements
  bundle check && bundle install
  cd
  rm -rf ~/bootstrap
EOF
