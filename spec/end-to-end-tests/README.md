# End-to-end tests

These tests aren't part of the applications, like rspec tests
are. They run independently, creating a test server and a database,
and deleting them at the end.

## Prerequisites

You need to install `nightwatch`, a node test runner (`npm install -g
nightwatch`). Other binaries needed (selenium, nightwatch, etc) are
included for MacOS.

Just run: `./run_fe_tests.sh`

## Debugging the app when tests fail

You can:

1. check the screenshots in the `screenshots` subdirectory
2. create a screenshot at a specific point with `.saveScreenshot('/tmp/screeshot.png')`
3. switch to a visual browser : change the `BROWSER_NAME` variable in `run_fe_tests.sh` (for instance, `chrome`). you can pause the test runner anywhere by using `.pause(10000)`, or any value in milliseconds.
