#!/bin/bash
export REDIS_URL=redis://$(echo $DOCKER_HOST | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'):6379
export POSTGRES_URL=postgres://postgres@$(echo $DOCKER_HOST | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'):5432/postgres
export MONGO_URL=mongodb://$(echo $DOCKER_HOST | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'):27017/badgify

export DATABASE_URL=$POSTGRES_URL

fig build postgres redis mongo
fig up -d postgres redis mongo
