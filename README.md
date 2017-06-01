## Publish Data

[![Code Climate](https://codeclimate.com/github/datagovuk/publish_data_beta/badges/gpa.svg)](https://codeclimate.com/github/datagovuk/publish_data_beta)

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

## Extra ENV vars for production
```
$ export PUBLISH_DATA_BETA_DATABASE_PASSWORD=...
$ export DATABASE_URL=...
```
