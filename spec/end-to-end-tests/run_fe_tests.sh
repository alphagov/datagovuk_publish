#!/bin/bash

# Where to find the app, and how to log in
export TEST_APP_PORT=3003
export APP_SERVER_URL=http://localhost:$TEST_APP_PORT
export USER_EMAIL=publisher@example.com
export ADMIN_USER_EMAIL=admin@example.com
export USER_PASSWORD=password

# Various executables needed to run tests
BIN=./bin/`uname`
export SELENIUM=./bin/selenium-server-standalone.jar
export GECKO_DRIVER=${BIN}/geckodriver
export PHANTOM_JS=${BIN}/phantomjs
export CHROME_DRIVER=${BIN}/chromedriver
export SECRET_KEY_BASE=test_key
export DEVISE_SECRET_KEY=test_key

# Which browser to use for tests (phantomjs, geckodriver or chrome)
export BROWSER_NAME=phantomjs

# Prefix for all test titles
export TEST_TITLE_PREFIX='TEST-'

# test database name
export DB_NAME=publish_beta_e2e_tests


# make sure we're in the right directory before we do anything
if [[ ! "$PWD" =~ spec/end-to-end-tests$ ]]; then
    echo "You must run this script in the spec/end-to-end-tests directory."
    exit
fi

trap kill_server SIGINT

function kill_server() {
    # kill test server
    echo Stopping test server at $PID
    kill -TERM $PID
}


# start test server
export DATABASE_URL=postgres://localhost:5432/$DB_NAME

echo Creating test database $DB_NAME
rake db:drop > /dev/null 2>&1
rake db:create > /dev/null 2>&1
rake db:migrate > /dev/null 2>&1
rake db:seed > /dev/null 2>&1
rake import:locations\['lib/seeds/locations.csv'\]

echo Starting test server
rm -f ../../tmp/pids/e2e-server.pid
rails s -p ${TEST_APP_PORT} -P tmp/pids/e2e-server.pid >/dev/null 2>&1 &
PID=$!

sleep 5
# run all tests
cd ../end-to-end-tests
nightwatch || true

# flush db
#cd ../src
#./manage.py delete_datasets --yes $TEST_TITLE_PREFIX

kill_server
echo Removing test database $DB_NAME
dropdb $DB_NAME
exit 0
