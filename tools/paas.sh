#!/bin/bash

# This script should be run in front of each command is run in a PaaS ssh session:
# eg.
# $ cf ssh publish-data-alpha/app/src
# > ../tools/paas.sh ./manage.py loaddata tasks

export HOME=/home/vcap/app
for f in ~/.profile.d/*; do
    echo $f
    source $f
done
$@
