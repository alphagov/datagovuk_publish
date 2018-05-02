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

## Getting Started

Run the following commands to get started.

```
# install dependencies
bin/setup

# import production data - ctrl-c after ~1000 datasets
bin/import

# start a web server
rails s
```

Then navigate to `http://localhost:3000`.

## Documentation

See [here](doc/adr/README.md) for all of our Architecture Decision Records.
