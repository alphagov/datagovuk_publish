#!/bin/bash

cf bgd publish-data-beta-staging staging-app-manifest.yml
cf bgd publish-data-beta-staging-worker staging-worker-manifest.yml
