# Publish Data
[![Build Status](https://travis-ci.org/datagovuk/publish_data_beta.svg?branch=master)](https://travis-ci.org/datagovuk/publish_data_beta)
[![Code Climate](https://codeclimate.com/github/datagovuk/publish_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/publish_data_beta)
[![Stories in Ready](https://badge.waffle.io/datagovuk/publish_data_beta.svg?label=ready&title=Ready)](http://waffle.io/datagovuk/publish_data_beta)

This repository contains the beta-stage data publishing component of data.gov.uk.

## Usage

### Ruby version
This application currently uses ruby v2.5.0. Use [RVM](https://rvm.io/) or similar to manage your ruby environment and sets of dependencies.

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

To avoid having to export SECRET_KEY_BASE each time you work on the application, you can instead copy .env.example to .env with `cp .env.example .env`

## Add seeds (dev example users, etc - do not use on production)

```
$ rake db:seed
```

> NB: db:seed does not include any datasets, you should use the 'Importing data' steps below

## Running tests
```
rails spec
```

## Fake user accounts
To log in as a fake user, use the credentials in 'seeds.rb' in the 'db' folder.

## Importing data
You can import data into Postgres using following commands:

```
rake import:locations[filename]
rake import:legacy_organisations[filename]
rake import:legacy_datasets[filename]
```

The locations are initially imported from the `db:seeds` command and you can obtain
data dumps for [datasets](https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.v2.jsonl.zip) and [organisations](https://data.gov.uk/data/dumps/data.gov.uk-ckan-meta-data-latest.organizations.jsonl.zip) from the legacy system.  You should unzip these files and use them as the filename arguments to the commands above.

Note:
- That organisations need to be imported before datasets.

## Reindex all datasets
You can reindex (Elasticsearch) all datasets using the following command:

```
rake search:reindex
```

The reindexing of elasticsearch is done using 'zero deploy' with the aim of minimising downtime for the end user. When running this command:
 - new index is created with the name 'datasets-[ENVIRONMENT]-[TIMESTAMP]'
 - the index alias ('datasets-[ENVIRONMENT]') is pointed to the new index.
 - A clean up job is then run to delete any old indexes. The most three recent indexes are kept in the event roll-back is required.


## Sync data

If you wish to only import datasets that were created or modified in the last
24 hours, you can run:

```
rake sync:beta
```

Note that this will import new / modified datasets into postgres and index in Elasticsearch


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
$ vagrant ssh -c "cd /vagrant && rails s"
$ vagrant ssh -c "cd /vagrant && bundle exec sidekiq
```
