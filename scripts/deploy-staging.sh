#!/bin/bash

rm manifest.yml || true
ln -s staging-app-manifest.yml manifest.yml
cf zero-downtime-push publish-data-beta-staging -f manifest.yml --show-app-log=true

rm manifest.yml
ln -s staging-worker-manifest.yml manifest.yml
cf zero-downtime-push publish-data-beta-staging-worker -f manifest.yml --show-app-log=true

rm manifest.yml
