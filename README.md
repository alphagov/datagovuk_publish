[![Code Climate](https://codeclimate.com/github/datagovuk/find_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/find_data_beta)
[![Test Coverage](https://codeclimate.com/github/datagovuk/find_data_beta/badges/coverage.svg)](https://codeclimate.com/github/datagovuk/find_data_beta/coverage)

# data.gov.uk Publish

This repository contains the beta-stage publishing component of data.gov.uk

## Prerequisites

You will need to install the following for development.

  * [rbenv](https://github.com/rbenv/rbenv) or similar to manage ruby versions
  * [bundler](https://rubygems.org/gems/bundler) to manage gems
  * [elasticsearch](https://www.elastic.co/) search engine
  * [postgresql](https://www.postgresql.org/) database

Most of these can be installed with Homebrew on a Mac.

## Developing on a Mac with a local CKAN installation

Install all the requirements for this app using Homebrew:

```
## PostgreSQL
brew install postgresql

## Redis
brew install redis

## Elasticsearch
brew tap caskroom/versions
brew cask install java8
brew install elasticsearch
```

Start the services on your machine:

```
brew services start postgresql
brew services start elasticsearch
brew services start redis
```

Configure the base URL of your local CKAN in `./config/environments/development.rb`:

```
config.ckan_v26_base_url = "http://localhost:4000"
```

Install dependencies, initialise the database and search index:

```
bin/setup
```

Start the web server:

```
rails s
```

Then navigate to `http://localhost:3000`.

To sync data from CKAN, set up the workers, then run Sidekiq to process the queue:

```
bin/rails runner CKAN::V26::CKANOrgSyncWorker.new.perform
bin/rails runner CKAN::V26::PackageSyncWorker.new.perform
bundle exec sidekiq
```

To completely clear the database, execute the following:

```
bin/rails db:drop db:setup
```

To re-index Elasticsearch based on the current database contents, run:

```
bin/rails search:reindex
```

## Documentation

See [here](doc/adr/README.md) for all of our Architecture Decision Records.
