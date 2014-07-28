#!/usr/bin/env zsh
source ~/.rvm/scripts/rvm

rvm use 2.1.2@coderwall

echo Converting github_repos
ruby bson2json.rb  < github_repos.bson    > github_repos.json
echo Converting github_profiles
ruby bson2json.rb  < github_profiles.bson > github_profiles.json
echo Converting teams
ruby bson2json.rb  < teams.bson           > teams.json
echo done
