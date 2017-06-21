#!/bin/bash

# Where to find the app, and how to log in
export TEST_APP_PORT=3003
export APP_SERVER_URL=http://localhost:$TEST_APP_PORT
export USER_EMAIL=publisher@example.com
export ADMIN_USER_EMAIL=admin@example.com
export USER_PASSWORD=password

# Various executables needed to run tests
export SELENIUM=${HOME}/bin/selenium-server-standalone.jar
export GECKO_DRIVER=${HOME}/bin/geckodriver
export PHANTOM_JS=${HOME}/bin/phantomjs
export CHROME_DRIVER=${HOME}/bin/chromedriver

# Which browser to use for tests (phantomjs, geckodriver or chrome)
export BROWSER_NAME=chrome

# Prefix for all test titles
export TEST_TITLE_PREFIX='TEST-'

# test database name
export DB_NAME=publish_beta_e2e_tests


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

echo Starting test server
rails s -p ${TEST_APP_PORT} >/dev/null 2>&1 &
PID=$!

sleep 5
# run all tests
cd ../end-to-end-tests
nightwatch tests/login.js || true

# flush db
#cd ../src
#./manage.py delete_datasets --yes $TEST_TITLE_PREFIX

kill_server
echo Removing test database $DB_NAME
dropdb $DB_NAME
exit 0
