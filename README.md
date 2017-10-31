# Publish Data
[![Build Status](https://travis-ci.org/datagovuk/publish_data_beta.svg?branch=master)](https://travis-ci.org/datagovuk/publish_data_beta)
[![Code Climate](https://codeclimate.com/github/datagovuk/publish_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/publish_data_beta)
[![Stories in Ready](https://badge.waffle.io/datagovuk/publish_data_beta.svg?label=ready&title=Ready)](http://waffle.io/datagovuk/publish_data_beta)

This repository contains the beta-stage data publishing component of data.gov.uk.

## Usage

### Ruby version
This application currently uses ruby v2.4.0. Use [RVM](https://rvm.io/)) or similar to manage your ruby environment and sets of dependencies.

### Installing ruby gems
To install gems (dependencies) you will need to first install [Bundler](http://bundler.io/)

### Databases
You will need Postgres and Elasticsearch installed for this to work.

On macOS both Postgres and Elasticsearch can be installed using [Homebrew](https://brew.sh/)

By default elastic is expected to be running on 127.0.0.1:9200 but if it isn't
you can override the value by exporting ES_HOST=http://.... but make sure the URL
does not end with a slash.

## Running the application
```
$ export SECRET_KEY_BASE=...
$ bundle install
$ rake db:create
$ rake db:migrate
$ rails s
```

## Add seeds (dev example users, etc - do not use on production)

```
$ rake db:seed
```
## Running tests
```
rails spec
```

## Fake user accounts
To log in as a fake user, use the credentials in 'seeds.rb' in the 'db' folder.

## Importing data
You can import data from source files using the following commands:

```
rake import:locations[locations.csv]
rake import:organisations[orgs.jsonl]
rake import:datasets[datasets.jsonl]
```

Note that organisations need to be imported before datasets.

If you wish to only import datasets that were modified in the last
24 hours, you can run:

```
rake sync:daily
```


## Generating 'tasks'.

### Checking for broken links

```
rake check:links:organisation[org-short-name]
rake check:links:dataset[dataset-short-name]
```

### Checking for overdue dataset

```
rake check:overdue:organisation[org-short-name]
rake check:overdue:dataset[dataset-short-name]
```

## Extra ENV vars for production
```
$ export PUBLISH_DATA_BETA_DATABASE_PASSWORD=...
$ export DATABASE_URL=...
```


# Vagrant

To run the app in a local VM with vagrant, install Vagrant and Virtualbox, then:
```
$ vagrant up
$ vagrant ssh -c /vagrant/tools/vagrant-dev-setup.sh
$ vagrant ssh -c "cd /vagrant && bundle install && rails s"
```
