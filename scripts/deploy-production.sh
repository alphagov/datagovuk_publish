#!/bin/bash

rm manifest.yml || true
ln -s production-app-manifest.yml manifest.yml
cf zero-downtime-push publish-data-beta -f manifest.yml --show-app-log=true


rm manifest.yml
ln -s production-worker-manifest.yml manifest.yml
cf zero-downtime-push publish-data-beta-worker -f manifest.yml --show-app-log=true

rm manifest.yml
