#!/bin/bash

ES_VERSION="0.90.9"

# ElasticSearch
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.deb
dpkg -i elasticsearch-$ES_VERSION.deb
