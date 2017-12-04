#!/usr/bin/env bash

print_warning() {
  echo -e "\033[1;33m"$1"\033[00m";
}

print() {
  echo -e "\033[1;32m"$1"\033[00m";
}

print_error() {
  echo -e "\033[1;31m"$1"\033[00m";
}

export SECRET_KEY_BASE="foobar"
bundle install
rails db:drop db:create db:schema:load db:seed

curl -O https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.organizations.jsonl.gz
curl -O https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.v2.jsonl.gz

gunzip data.gov.uk-ckan-meta-data-latest.organizations.jsonl.gz
gunzip data.gov.uk-ckan-meta-data-latest.v2.jsonl.gz

print "Adding locations"
rails import:locations["lib/seeds/locations.csv"]

print "Adding organisations"
rails import:legacy_organisations["data.gov.uk-ckan-meta-data-latest.organizations.jsonl"]

print "Adding datasets"
rails import:legacy_datasets["data.gov.uk-ckan-meta-data-latest.v2.jsonl"]

print "Cleaning up"
rm data.gov.uk-ckan-meta-data-latest.organizations.jsonl data.gov.uk-ckan-meta-data-latest.v2.jsonl

print "All done."
