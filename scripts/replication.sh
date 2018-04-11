#!/usr/bin/env bash

set -e

mkdir -p tmp/backups

cf login -a api.cloud.service.gov.uk
cf install-plugin conduit
cf conduit publish-beta-staging-pg -- pg_dump -Fc --no-acl --no-owner --file=tmp/backups/pg.dump
pg_restore --verbose --clean --no-acl --no-owner -d publish_data_beta_development tmp/backups/pg.dump
rails db:environment:set RAILS_ENV=development
psql publish_data_beta_development -c "drop function reassign_owned() cascade;"
rails db:migrate