/* global $, Bloodhound */

var locations = {}

locations._options = {
  hint: true,
  highlight: true,
  minLength: 2,
  classNames: {
    input: 'form-control tt-input',
    hint: 'form-control tt-hint'
  }
}

locations._sourceOptions = {
  name: 'states',
  source: new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      url: '/api/locations?q=%QUERY',
      wildcard: '%QUERY'
    }
  })
}

// hide something, show something
locations._hs = function (stuffToHideSelector, stuffToShowSelector) {
  if (stuffToHideSelector) $(stuffToHideSelector).attr('aria-hidden', 'true').hide()
  if (stuffToShowSelector) $(stuffToShowSelector).attr('aria-hidden', 'false').show()
}

// what to do when the first 'Add another area' button is clicked
locations._add1 = function () {
  locations._hs('#add1', '#location2, #add2, #del1, #del2')
}

// what to do when the second 'Add another area' button is clicked
locations._add2 = function () {
  locations._hs('#add2', '#location3, #del2, #del3')
}

// what to do when the first 'Remove' button is clicked
locations._del1 = function () {
  // we've remove the first location, copy the 2 others down
  $('#id_location1').val($('#id_location2').val())
  $('#id_location2').val($('#id_location3').val())

  // second location field disappears if not third present
  if (!$('#location3').is(':visible')) {
    locations._hs('#location2, #add2', '#add1')
  } else {
    locations._hs('', '#add2')
  }
  if (!$('#location2').is(':visible')) {
    locations._hs('#del1')
  }
  locations._hs('#location3')
  $('#location3').val('')
}

// second Remove button is clicked
locations._del2 = function () {
  $('#id_location2').val($('#id_location3').val())
  $('#id_location3').val('')
  if (!$('#location3').is(':visible')) {
    locations._hs('#location2, #add2, #del1, #del2', '#add1')
  } else {
    locations._hs('', '#add2')
  }
  locations._hs('#location3')
}

locations._del3 = function () {
  $('#id_location3').val('')
  locations._hs('#location3', '#add2')
}

locations.init = function (params) {
  $.each(params, function (key, val) {
    locations._options[key] = val
  })

  // Removing Enter key as submit, as it makes
  // it confusing to use with a screen reader
  $('#id_location1, #id_location2, #id_location3')
    .on('keypress', function (e) { return e.which !== 13 })

  if ($('#id_location2').val()) {
    locations._hs('#add1', '#location2, #add2, #del2, #del1')
  } else {
    locations._hs('', '#add1')
  }

  if ($('#id_location3').val()) {
    locations._hs('#add2', '#location3, #del3')
  }

  $('#add1').on('click', locations._add1)
  $('#add2').on('click', locations._add2)
  $('#del1').on('click', locations._del1)
  $('#del2').on('click', locations._del2)
  $('#del3').on('click', locations._del3)

  $(params.selector).typeahead(locations._options, locations._sourceOptions)
}
