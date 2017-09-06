!/usr/bin/env bash

print_warning() {
  echo -e "\033[1;33m"$1"\033[00m";
}

print_error() {
  echo -e "\033[1;31m"$1"\033[00m";
}

export SECRET_KEY_BASE="foobar"
bundle install
rails db:create db:migrate db:seed

if type wget > /dev/null 2>&1; then
  print_warning "wget found at '`which wget`', moving on."
  wget https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.organizations.jsonl.gz
  wget https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.v2.jsonl.gz
else
  print_error "Please install wget and run this script again."
fi

gunzip data.gov.uk-ckan-meta-data-latest.organizations.jsonl.gz
gunzip data.gov.uk-ckan-meta-data-latest.v2.jsonl.gz

rails import:locations["lib/seeds/locations.csv"]
rails import:organisations["data.gov.uk-ckan-meta-data-latest.organizations.jsonl"]
rails import:datasets["data.gov.uk-ckan-meta-data-latest.v2.jsonl"]
