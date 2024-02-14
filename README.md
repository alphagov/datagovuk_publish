[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# data.gov.uk Publish

This repository contains the beta-stage publishing component of data.gov.uk.

## Deployment

See [the developer docs on data.gov.uk deployment](https://docs.publishing.service.gov.uk/manual/data-gov-uk-deployment.html)

## Prerequisites

You will need to install the following for development.

  * [rbenv](https://github.com/rbenv/rbenv) or similar to manage ruby versions
  * [bundler](https://rubygems.org/gems/bundler) to manage gems
  * [opensearch](https://opensearch.org/) search engine
  * [postgresql](https://www.postgresql.org/) database

Most of these can be installed with Homebrew on a Mac.

## How to run this repo locally

There are currently 2 ways to run this repo locally:

1. Via  [govuk-dgu-charts](https://github.com/alphagov/govuk-dgu-charts) - An end to end setup from ckan to opensearch to Find. This is the presently most supported means for running Find and is recommended for local development. Instructions for how to setup and run Find this way available on the linked repo.
2. Manual installation. Instructions for this below. (needs CKAN running)

### Install requirements for this app using Homebrew

```
## PostgreSQL
brew install postgresql

## Redis
brew install redis

## Opensearch
brew tap caskroom/versions
brew cask install java8
brew install opensearch
```

### Start the services on your machine

```
brew services start postgresql
brew services start opensearch
brew services start redis
```

### Update config settings

Configure the base URL of your local CKAN in [./config/environments/development.rb](https://github.com/alphagov/datagovuk_publish/blob/master/config/environments/development.rb#L57):

```
config.ckan_v26_base_url = "http://localhost:4000"
```

### Install dependencies, initialise the database and search index:

```
bin/setup
```

### Start the web server

```
rails s
```

Then navigate to `http://localhost:3000`.

### Run Sidekiq jobs

These need to be run to sync data from CKAN.

Set up the workers, these sync organisation data and their datasets:

```
bin/rails runner CKAN::V26::CKANOrgSyncWorker.new.perform
bin/rails runner CKAN::V26::PackageSyncWorker.new.perform
```
Then run Sidekiq to process the queue:

```
bundle exec sidekiq
```
When you create new organisations and datasets in Publish, you will have to run these commands again to trigger the sync. These should then appear in Find.

### Clear the database

To completely clear the database:

```
bin/rails db:drop db:setup
```

### Re-index Opensearch

To re-index Opensearch based on the current database contents, run:

```
bin/rails search:reindex
```

## Troubleshooting

### Flush Redis

This may be necessary if you're having issues trying to completely reset your CKAN stack and start over with no data. See the next section below as an example.

```
$ redis-cli flushall
OK
```

Check the database size is 0:
```
$ redis-cli
127.0.0.1:6379> dbsize
(integer) 0
```

### Delete the index on opensearch

If when attempting to run `bin/rails search:reindex` you get `An alias can not be assigned to index of the same name. Please delete index 'datasets-development' before continuing`, then you should run the following command on the publish pod before running the search reindex:

```
$ curl -XDELETE $ES_HOST/datasets-development
```

### Running the PackageSyncWorker sidekiq job attempts to sync non existent data

When running this sidekiq job it returns errors in the terminal such as:

```
404 Not Found excluded from capture: DSN not set
{"@timestamp":"2019-06-06T10:03:58Z","@fields":{"pid":43034,"tid":"TID-oxw3pfczg","context":" CKAN::V26::PackageImportWorker JID-3b2dff4c5d230d1d27cc5bea","program_name":null,"worker":"CKAN::V26::PackageImportWorker"},"@type":"sidekiq","@status":"fail","@severity":"INFO","@run_time":0.545,"@message":"fail: 0.545 sec"}
```

1. Ensure you have the correct config settings - see [Update config settings](#update-config-settings)
2. Try to [flush redis](#flush-redis)
3. You will also need to [purge SOLR via CKAN](https://docs.ckan.org/en/ckan-2.7.3/maintaining/paster.html#search-index-rebuild-search-index)
4. [Clear the Publish database](#clear-the-database)
5. Then re-run sidekiq jobs - see [Run sidekiq jobs](#run-sidekiq-jobs)

## Documentation

See [here](docs/adr/README.md) for all of our Architecture Decision Records.
