#!/bin/bash

cf bgd publish-data-beta production-app-manifest.yml
cf bgd publish-data-beta-worker production-worker-manifest.yml
