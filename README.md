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

## Generating tasks

### Checking for broken links

```
rake linkcheck:organisation[org-short-name]
rake linkcheck:dataset[dataset-short-name]
```

### Checking for overdue dataset

```
rake overduecheck:organisation[org-short-name]
rake overduecheck:dataset[dataset-short-name]
```

## Extra ENV vars for production
```
$ export PUBLISH_DATA_BETA_DATABASE_PASSWORD=...
$ export DATABASE_URL=...
```
