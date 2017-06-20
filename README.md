## Publish Data

[![Build Status](https://travis-ci.org/datagovuk/publish_data_beta.svg?branch=master)](https://travis-ci.org/datagovuk/publish_data_beta)
[![Code Climate](https://codeclimate.com/github/datagovuk/publish_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/publish_data_beta)
[![Stories in Ready](https://badge.waffle.io/datagovuk/publish_data_beta.svg?label=ready&title=Ready)](http://waffle.io/datagovuk/publish_data_beta)

This repository contains the beta-stage data publishing component of data.gov.uk.

# Usage

## First time setup
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

## Importing data

You can import data from source files using the following commands:

```
rake import:locations[locations.csv]
rake import:organisations[orgs.jsonl]
rake import:datasets[datasets.jsonl]
```

Note that organisations need to be imported before datasets.

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
