module.exports = (function(settings) {
  settings.selenium.server_path =
    process.env.SELENIUM;

  settings.selenium.cli_args["webdriver.gecko.driver"] =
    process.env.GECKO_DRIVER;

  settings.selenium.cli_args["webdriver.phantomjs"] =
    process.env.PHANTOM_JS;

  settings.test_settings.default.desiredCapabilities["phantomjs.binary.path"] =
    process.env.PHANTOM_JS;

  settings.test_settings.default.desiredCapabilities.browserName =
    process.env.BROWSER_NAME;

  return settings;

})(require('./nightwatch.json'));
