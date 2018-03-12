#!/bin/bash

cf zero-downtime-push publish-data-beta -f production-app-manifest.yml --show-app-log=true
cf zero-downtime-push publish-data-beta-worker -f production-worker-manifest.yml --show-app-log=true
