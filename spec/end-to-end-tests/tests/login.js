var common = require('../common.js')

var test_login = function(browser) {
  common.extended(browser)
    .url(process.env.APP_SERVER_URL)
    .waitForElementVisible('body', common.waitTimeout)
    .assert.containsText('h1', 'Publish and update data')
    .clickOnLink('Sign in')
    .waitForElementVisible('main', common.waitTimeout)
    .assert.containsText('h1', 'Sign in')
    .clearSetValue('input[name=email]', process.env.USER_EMAIL)
    .clearSetValue('input[name=password]', process.env.USER_PASSWORD)
    .submitFormAndCheckNextTitle('Tasks')
    .end();
};

var test_failed_login = function(browser) {
  common.extended(browser)
    .url(process.env.APP_SERVER_URL)
    .waitForElementVisible('body', common.waitTimeout)
    .assert.containsText('h1', 'Publish and update data')
    .clickOnLink('Sign in')
    .waitForElementVisible('main', common.waitTimeout)
    .assert.containsText('h1', 'Sign in')
    .clearSetValue('input[name=email]', 'foo@bar.baz')
    .clearSetValue('input[name=password]', 'qux')
    .submitFormAndCheckNextTitle('There was a problem signing you in')
    .end();
};

var test_logout = function(browser) {
  common.extended(browser)
    .url(process.env.APP_SERVER_URL)
    .waitForElementVisible('body', common.waitTimeout)
    .assert.containsText('h1', 'Publish and update data')
    .clickOnLink('Sign in')
    .waitForElementVisible('main', common.waitTimeout)
    .assert.containsText('h1', 'Sign in')
    .clearSetValue('input[name=email]', process.env.USER_EMAIL)
    .clearSetValue('input[name=password]', process.env.USER_PASSWORD)
    .submitFormAndCheckNextTitle('Tasks')
    .clickOnLink('Sign out')
    .assert.containsText('h1', 'Publish and update data')
    .end();
};

var test_userpage = function(browser) {
  common.login(browser, process.env.USER_EMAIL, process.env.USER_PASSWORD)
    .click('a[href^="/accounts/user/"]')
    .waitForElementVisible('h1', common.waitTimeout)
    .assert.containsText('h1', 'Your account')
    .assert.containsText('ul.user-details', process.env.USER_EMAIL)
    .end()
};

module.exports = {
  'Successful login': test_login,
  'Successful logout': test_logout,
  'Failed login': test_failed_login,
  'User account page': test_userpage
}
