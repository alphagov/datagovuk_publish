#!/bin/bash

set -e

cf zero-downtime-push publish-data-beta-staging -f staging-app-manifest.yml --show-app-log=true
cf zero-downtime-push publish-data-beta-staging-worker -f staging-worker-manifest.yml --show-app-log=true
