# End-to-end tests

These tests aren't part of the applications, like rspec tests
are. They run independently, creating a test server and a database,
and deleting them at the end.

## Prerequisites

You need to install `nightwatch`, a node test runner (`npm install -g
nightwatch`). Other binaries needed (selenium, nightwatch, etc) are
included for MacOS.

Just run: `./run_fe_tests.sh`
