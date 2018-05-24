#!/bin/bash

set -e

cf zero-downtime-push publish-data-beta-production -f production-app-manifest.yml --show-app-log=true
cf zero-downtime-push publish-data-beta-production-worker -f production-worker-manifest.yml --show-app-log=true
