var common = require('../common.js')

// ============ shortcut functions =============================================

var goToCreateTitle = function(browser) {
  return common.login(browser, process.env.USER_EMAIL, process.env.USER_PASSWORD)
    .clickAndCheckNextTitle('Manage data', 'Manage your data')
    .clickAndCheckNextTitle('Create a dataset', 'Create a dataset');
};

var goToCreateLicence = function(browser) {
  return goToCreateTitle(browser)
    .clearSetValue('input[name="dataset[title]"]', common.datasetTitle)
    .clearSetValue('textarea[name="dataset[summary]"]', 'Summary of my dataset')
    .clearSetValue('textarea[name="dataset[description]"]', 'Description of my dataset')
    .submitFormAndCheckNextTitle('Choose a licence');
};

var goToCreateRegion = function(browser) {
  return goToCreateLicence(browser)
    .selectRadioButton('Open Government Licence')
    .submitFormAndCheckNextTitle('Choose a geographical area');
};

var goToCreateFrequency = function(browser) {
  return goToCreateRegion(browser)
    .clearSetValue('#id_location1', 'England')
    .clearSetValue('#id_location2', 'Wales')
    .submitFormAndCheckNextTitle('How frequently is this dataset updated?');
};

var goToDocumentation = function(browser) {
  return goToCreateFrequency(browser)
    .selectRadioButton('Annually (January to December)')
    .submitFormAndCheckNextTitle('Add a link')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#id_name', common.datafileTitle)
    .clearSetValue('#period_year', '2013')
    .submitFormAndCheckNextTitle('Links to your data')
    .clickAndCheckNextTitle(
      'Save and continue',
      'Add a link to supporting documents'
    );
};

var goToCheckPage = function(browser) {
  return goToDocumentation(browser)
    .clearSetValue('#id_name', common.docTitle)
    .clearSetValue('#id_url', common.validDataUrl)
    .submitFormAndCheckNextTitle('Links to supporting documents')
    .clickAndCheckNextTitle(
      'Save and continue',
      'Publish ‘' + common.datasetTitle  + '’'
    );
};

var createDataset = function(browser) {
  return goToCheckPage()
    .submitFormAndCheckNextTitle('Your dataset has been published');
};



// ============ here start the tests ===========================================


var test_create_happy_path = function (browser) {
  common.login(browser, process.env.USER_EMAIL, process.env.USER_PASSWORD)
    .clickAndCheckNextTitle('Manage data', 'Manage your data')
    .clickAndCheckNextTitle('Create a dataset', 'Create a dataset')
    .clearSetValue('input[name="dataset[title]"]', common.datasetTitle)
    .clearSetValue('textarea[name="dataset[summary]"]', 'Summary of my dataset')
    .clearSetValue('textarea[name="dataset[description]"]', 'Description of my dataset')
    .submitFormAndCheckNextTitle('Choose a licence')
    .selectRadioButton('Open Government Licence')
    .submitFormAndCheckNextTitle('Choose a geographical area')
    .clearSetValue('#id_location1', 'England, Wales')
    .submitFormAndCheckNextTitle('How frequently is this dataset updated?')
    .selectRadioButton('Monthly')
    .submitFormAndCheckNextTitle('Add a link')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#id_name', common.datafileTitle)
    .clearSetValue('#start_month', '12')
    .clearSetValue('#start_year', '2016')
    .submitFormAndCheckNextTitle('Links to your data')
    .clickAndCheckNextTitle('Save and continue', 'Add a link to supporting documents')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#id_name', common.docTitle)
    .submitFormAndCheckNextTitle('Links to supporting documents')
    .clickAndCheckNextTitle('Save and continue', 'Publish ‘' + common.datasetTitle  + '’')
    .assert.containsText('table', 'Open Government Licence')
    .submitFormAndCheckNextTitle('Your dataset has been published')
    .end();
};

var test_create_invalid_title = function (browser) {
  goToCreateTitle(browser)
    .clearSetValue('input[name="dataset[title]"]', '][;')
    .clearSetValue('textarea[name="dataset[summary]"]', 'Summary of my dataset')
    .clearSetValue('textarea[name="dataset[description]"]', 'Description of my dataset')
    .submitFormAndCheckNextTitle('There was a problem')
    .checkError('Please enter a valid title')
    .clearSetValue('input[name="dataset[title]"]', common.datasetTitle)
    .submitFormAndCheckNextTitle('Choose a licence')
    .end();
};

var test_create_region_autocomplete = function (browser) {
  goToCreateRegion(browser)
    .clearSetValue('#id_location1', 'Swa')
    .waitForElementVisible('div.tt-menu', 5000)
    .assert.containsText('div.tt-menu', 'Swansea (local authority)')
    .end();
};

var test_create_quarterly = function (browser) {
  goToCreateFrequency(browser)
    .selectRadioButton('Quarterly')
    .submitFormAndCheckNextTitle('Add a link')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#id_name', common.datafileTitle)
    .clearSetValue('#period_year', '1981')
    .selectRadioButton('Q2 (July to September)')
    .submitFormAndCheckNextTitle('Links to your data')
    .clickOnLink('Add another link')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#id_name', common.datafileTitle2)
    .selectRadioButton('Q3 (October to December)')
    .clearSetValue('#period_year', '1984')
    .submitFormAndCheckNextTitle('Links to your data')
    .assert.containsText('table', common.datafileTitle)
    .assert.containsText('table', common.datafileTitle2)
    .end();
};

var test_create_never = function (browser) {
  goToCreateFrequency(browser)
    .selectRadioButton('One-off')
    .submitFormAndCheckNextTitle('Add a link')
    .end();
};

var test_create_yearly = function (browser) {
  goToCreateFrequency(browser)
    .selectRadioButton('Annually (January to December)')
    .submitFormAndCheckNextTitle('Add a link')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#id_name', common.datafileTitle)
    .clearSetValue('#period_year', '2012')
    .submitFormAndCheckNextTitle('Links to your data')
    .clickOnLink('Add another link')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#id_name', common.datafileTitle2)
    .clearSetValue('#period_year', '2013')
    .submitFormAndCheckNextTitle('Links to your data')
    .assert.containsText('table', common.datafileTitle)
    .assert.containsText('table', common.datafileTitle2)
    .end();
};

var test_create_financial_yearly = function (browser) {
  goToCreateFrequency(browser)
    .selectRadioButton('Annually (financial year April to March)')
    .submitFormAndCheckNextTitle('Add a link')
    .clearSetValue('#id_name', 'Some link')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#period_year', '1984')
    .submitFormAndCheckNextTitle('Links to your data')
    .end();
};

var test_create_yearly_bad_year = function (browser) {
  goToCreateFrequency(browser)
    .selectRadioButton('Annually (financial year April to March)')
    .submitFormAndCheckNextTitle('Add a link')
    .clearSetValue('#id_url', common.validDataUrl)
    .clearSetValue('#id_name', common.datafileTitle)
    .clearSetValue('#period_year', 'meh')
    .submitFormAndCheckNextTitle('There was a problem')
    .checkError('Please enter a valid year')
    .clearSetValue('#period_year', '10234')
    .submitFormAndCheckNextTitle('There was a problem')
    .checkError('Please enter a valid year')
    .clearSetValue('#period_year', '123')
    .submitFormAndCheckNextTitle('There was a problem')
    .checkError('Please enter a valid year')
    .clearSetValue('#period_year', '2010')
    .submitFormAndCheckNextTitle('Links to your data')
    .end();
};

var test_create_omit_url = function (browser) {
  goToCreateFrequency(browser)
    .selectRadioButton('Annually (January to December)')
    .submitFormAndCheckNextTitle('Add a link')
    .submitFormAndCheckNextTitle('There was a problem')
    .checkError('Please enter a valid name')
    .checkError('Please enter a valid URL')
    .checkError('Please enter a valid year')
    .end();
};

var test_create_modify_title = function (browser) {
  goToCheckPage(browser)
    .click('td.dgu-checklist__actions a')
    .waitForElementVisible('h1', common.waitTimeout)
    .assert.containsText('h1', 'Change your dataset\'s details')
    .clearSetValue('input[name="dataset[title]"]', common.datasetTitle2)
    .submitFormAndCheckNextTitle('Publish ‘' + common.datasetTitle2 + '’')
    .end();
};

var test_create_modify_licence = function (browser) {
  goToCheckPage(browser)
    .click('a[href*="licence"]')
    .waitForElementVisible('h1', common.waitTimeout)
    .assert.containsText('h1', 'Choose a licence')
    .selectRadioButton('Other')
    .clearSetValue('input[name="dataset[licence_other]"]', 'my licence')
    .submitFormAndCheckNextTitle('Publish ‘' + common.datasetTitle  + '’')
    .waitForElementVisible('body', common.waitTimeout)
    .assert.containsText('body', 'my licence')
    .end();
};

var test_create_remove_link = function (browser) {
  goToCheckPage(browser)
    .click('a[href*="files"]')
    .waitForElementVisible('h1', common.waitTimeout)
    .assert.containsText('h1', 'Links to your data')
    .clickAndCheckNextTitle(
      'Delete',
      'Are you sure you want to delete ‘' + common.datafileTitle  + '’?'
    )
    .clickAndCheckNextTitle(
      'Yes',
      'Your link ‘' + common.datafileTitle + '’ has been deleted'
    )
    .clickAndCheckNextTitle('Save and continue', 'Publish ‘' + common.datasetTitle  + '’')
    .end();
};

var test_create_remove_doc = function (browser) {
  goToCheckPage(browser)
    .click('a[href*="documents"]')
    .waitForElementVisible('h1', common.waitTimeout)
    .assert.containsText('h1', 'Links to supporting documents')
    .clickAndCheckNextTitle(
      'Delete',
      'Are you sure you want to delete ‘' + common.docTitle  + '’?'
    )
    .clickAndCheckNextTitle(
      'Yes',
      'Your link ‘' + common.docTitle + '’ has been deleted'
    )
    .clickAndCheckNextTitle('Save and continue', 'Publish ‘' + common.datasetTitle  + '’')
    .end();
};

var test_create_add_file_twice = function (browser) {
  goToDocumentation(browser)
    .back()
    .back()
    .submitFormAndCheckNextTitle('Links to your data')
    .assert.elementNotPresent('#file_2')
    .end();
};

module.exports = {
  'Create a dataset, happy path': test_create_happy_path,
//  'Create a dataset, invalid title': test_create_invalid_title,
  'Create a dataset, region autocomplete': test_create_region_autocomplete,
  'Create a dataset, frequency daily': test_create_daily,
  'Create a dataset, frequency daily, omit link': test_create_daily_omit_link,
  'Create a dataset, frequency weekly': test_create_weekly,
  'Create a dataset, frequency monthly': test_create_monthly,
  'Create a dataset, monthly, bad month': test_create_monthly_bad_month,
  'Create a dataset, monthly, bad year': test_create_monthly_bad_year,
  'Create a dataset, yearly, bad year': test_create_yearly_bad_year,
  'create a dataset, frequency quarterly': test_create_quarterly,
  'Create a dataset, frequency never': test_create_never,
  'Create a dataset, frequency yearly': test_create_yearly,
  'Create a dataset, frequency financial yearly': test_create_financial_yearly,
  'Create a dataset, omit url': test_create_omit_url,
  'Create a dataset, modify title': test_create_modify_title,
  'Create a dataset, modify licence': test_create_modify_licence,
  'Create a dataset, remove link after check': test_create_remove_link,
  'Create a dataset, remove doc after check': test_create_remove_doc,
  'Create a dataset, add file twice': test_create_add_file_twice
};
