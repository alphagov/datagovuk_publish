/* eslint-disable no-unused-expressions */
/* global $, Locations */

;(function () {
  'use strict'

  // Utilities

  // escape strings injected into the DOM
  function safeText (str) {
    var div = document.createElement('div')
    div.appendChild(document.createTextNode(str))
    return div.innerHTML
  }

  // query string management
  function splitUrl (url) {
    var match
    var pl = /\+/g // Regex for replacing addition symbol with a space
    var search = /([^&=]+)=?([^&]*)/g
    var decode = function (s) { return decodeURIComponent(s.replace(pl, ' ')) }
    var query = window.location.search.substring(1)
    var urlParams = {
      base: window.location.origin + window.location.pathname,
      params: {}
    }
    match = search.exec(query)
    if (match) {
      urlParams.params[decode(match[1])] = decode(match[2])
    }
    return urlParams
  }

  function buildUrl (urlObj) {
    var queryString = ''
    for (var param in urlObj.params) {
      if (urlObj.params.hasOwnProperty(param)) {
        queryString +=
          (queryString === '' ? '?' : '&') +
          param + '=' + urlObj.params[param]
      }
    }
    return urlObj.base + queryString
  }

  // Components

  var searchDatasetsAsYouType = {

    buildResultsTable: function (results) {
      $('#dataset-list').html('')
      results.forEach(function (item) {
        var safeName = encodeURIComponent(item.name)
        var safeTitle = safeText(item.title)
        var findUrl = $('#find-url').text()
        var markup = '<tr><td><a href="' + findUrl + '/dataset/' +
          safeName + '">' + safeTitle +
          '</a></td><td>' +
          (item.published ? 'Published' : 'Draft') +
          '</td><td class="actions">' +
          '<a href="/dataset/' +
          safeName +
          '/addfile/">Add&nbspData</a>' +
          '<a href="/dataset/edit/' +
          safeName +
          '">Edit</a></td></tr>'
        $('#dataset-list').append(markup)
      })
    },

    buildPagination: function ($paginationSection, numResults, searchQuery) {
      $paginationSection.html('')
      if (numResults > 20) {
        for (var i = 1; i <= Math.ceil(numResults / 20); i++) {
          $paginationSection.append(
            '<span><a href="?page=' + i + '&ampq=' + searchQuery + '">' +
              i + '</a> </span>'
          )
        }
      }
    },

    changeSortLinks: function (searchQuery) {
      $('.dgu-sortable-column__heading').each(function () {
        var link = $(this).find('a')
        var hrefObj = splitUrl(link.attr('href'))
        hrefObj.params.q = searchQuery
        link.attr('href', buildUrl(hrefObj))
      })
    },

    suggestOk: function (response) {
      var safeSearchQuery = encodeURIComponent(this.value)
      var self = this
      var numResults = response.total
      var $paginationSection = $('.pagination')

      if (numResults === 0) {
        $('.manage-data').hide()
        $('.noresults').show()
      } else {
        var searchResults = response.datasets

        $('.manage-data').show()
        $('.noresults').hide()

        // rebuild the table with results
        self.buildResultsTable(searchResults)
        self.changeSortLinks(safeSearchQuery)
      }

      self.buildPagination(
        $paginationSection,
        numResults,
        safeSearchQuery
      )
    },

    keyCallback: function (event) {
      if (event.which === 0 ||
          event.which === 9 || // tab
          event.which === 16 || // shift-tab
          event.ctrlKey ||
          event.metaKey ||
          event.altKey) {
        return
      }
      $.get('/api/datasets?q=' + this.value).success(this.suggestOk.bind(this))
    },

    init: function () {
      $('#filter-dataset-form #q').on('keyup', this.keyCallback.bind(this))
    }
  }

  var analytics = {
    init: function () {
      if (!window.ga) return
      $('[data-ga-action]').each(function (i, el) {
        var action = $(el).data('ga-action')
        if (action) {
          var actionParams = ['send', 'event', 'dataset'].concat(action.split(','))
          window.ga.apply(this, actionParams)
        }
      })
    }
  }

  $(document).ready(function () {

    var showHideContent = new GOVUK.ShowHideContent()
    showHideContent.init()


    showAll.init({ rowLimit: 5 })
    locations.init({ selector: '.dgu-location__input' })
    searchDatasetsAsYouType.init('#filter-dataset-form')
    analytics.init()
  })
})()
