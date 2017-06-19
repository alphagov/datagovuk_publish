!(function () {
  'use strict';

  // Utilities

  // hide something, show something
  var hs = function(stuffToHideSelector, stuffToShowSelector) {
    if (stuffToHideSelector) $(stuffToHideSelector).attr('aria-hidden', 'true').hide();
    if (stuffToShowSelector) $(stuffToShowSelector).attr('aria-hidden', 'false').show();
  };

  // escape strings injected into the DOM
  function safeText(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  // query string management
  function splitUrl(url) {
    var match;
    var pl     = /\+/g;  // Regex for replacing addition symbol with a space
    var search = /([^&=]+)=?([^&]*)/g;
    var decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); };
    var query  = window.location.search.substring(1);
    var urlParams = {
      base: window.location.origin + window.location.pathname,
      params: {}
    };

    while (match = search.exec(query)) {
     urlParams.params[decode(match[1])] = decode(match[2]);
    }
    return urlParams;
  }

  function buildUrl(urlObj) {
    var queryString = '';
    for (var param in urlObj.params) {
      queryString +=
        (queryString == '' ? '?' : '&') +
        param + '=' + urlObj.params[param];
    }
    return urlObj.base + queryString;
  }

  // Components

  var showHide = {
    selector: '.show-hide',

    init: function(params) {
      var that = this;
      $.each($(this.selector), function(index, showHide) {
        var rows = $(showHide).find('.show-hide-item');
        rows.each(function() {
          if ($(this).index() >= params.rowLimit) {
            $(this).hide();
          }
        });
        if (rows.length > params.rowLimit) {
          $(showHide).find('a.toggle')
            .on('click', params, that.callback)
            .show();
        }
      });
    },

    callback: function(event) {
      var a = $(this);
      var rows = $(this).parents('.show-hide').first().find('.show-hide-item');
      a.toggleClass('expanded');
      if (a.hasClass('expanded')) {
        a.text('Close');
        rows.show();
      } else {
        a.text('Show all');
        rows.each(function(i) {
          if ($(this).index() >= event.data.rowLimit) $(this).hide();
        });
      }
    }
  };

  var typeAhead = {
    options: {
      hint: true,
      highlight: true,
      minLength: 2,
      classNames: {
        input: 'form-control tt-input',
        hint: 'form-control tt-hint'
      }
    },

    sourceOptions: {
      name: 'states',
      source: new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        remote: {
          url: '/api/locations?q=%QUERY',
          wildcard: '%QUERY'
        }
      })
    },

    // what to do when the first 'Add another area' button is clicked
    add1: function() { hs('#add1', '#location2, #add2, #del1, #del2') },

    // what to do when the second 'Add another area' button is clicked
    add2: function() { hs('#add2', '#location3, #add2, #del2, #del3') },

    // what to do when the first 'Remove' button is clicked
    del1: function() {
      // we've remove the first location, copy the 2 others down
      $('#id_location1').val($('#id_location2').val());
      $('#id_location2').val($('#id_location3').val());

      // second location field disappears if not third present
      if (!$('#location3').is(':visible')) {
        hs('#location2, #add2', '#add1');
      } else {
        hs('', '#add2');
      }
      if (!$('#location2').is(':visible')) {
        hs('#del1');
      }
      hs('#location3');
      $('#location3').val('');
    },

    // second Remove button is clicked
    del2: function() {
      $('#id_location2').val($('#id_location3').val());
      $('#id_location3').val('');
      if (!$('#location3').is(':visible')) {
        hs('#location2, #add2, #del1, #del2', '#add1');
      } else {
        hs('', '#add2');
      }
      hs('#location3');
    },

    del3: function() {
      $('#id_location3').val('');
      hs('#location3', '#add2');
    },

    init: function(params) {

      // Removing Enter key as submit, as it makes
      // it confusing to use with a screen reader
      $('#id_location1, #id_location2, #id_location3')
        .on('keypress', function(e) { return e.which !== 13; });

      if ($('#id_location2').val()) {
        hs('#add1', '#location2, #add2, #del2');
      } else {
        hs('', '#add1');
      }

      if ($('#id_location3').val()) {
        hs('#add2', '#location3, #del3');
      }

      $('#add1').on('click', this.add1);
      $('#add2').on('click', this.add2);
      $('#del1').on('click', this.del1);
      $('#del2').on('click', this.del2);
      $('#del3').on('click', this.del3);

      $(params.selector).typeahead(this.options, this.sourceOptions);
    },
  };

/*
  var stats = {

    fetchStats: function() {
      $.get(this.endpoint + 'stats/?orgs=' + this.orgs.join())
        .done($.proxy(this.makeStatsMarkup, this))
        .fail(function(xhr, text, error) {
          console.log('fail: ', text, error);
        })
    },

    statText: function(stat) {
      switch(stat.statistic) {
        // TODO: make it easier to translate the text
        case 'view': return 'Views: ' + stat.total;
        case 'download': return 'Downloads: ' + stat.total;
        case 'search': return 'Searched: ' + stat.total;
        default: return '';
      }
    },

    makeStatsMarkup: function(data) {
      var $tbody = this.$statsSection.find('table tbody');
      var $rowTemplate = $('#row-template');
      $.each(data, function(index, datum) {
        var $newRow = $rowTemplate.clone().removeAttr('id style');
        var statText = stats.statText(datum);
        if (datum.dataset_title && statText) {
          $newRow
            .find('.stats-title')
            .text(datum.dataset_title);
          $newRow
            .find('.stats-downloads')
            .text(statText);
          $tbody.append($newRow);
        }
      });
      this.$statsSection.removeClass('js-hidden');
    },

    init: function(selector) {
      this.$statsSection = $(selector);
      if (this.$statsSection.length) {
        this.endpoint = $('#api-endpoint').text();
        this.orgs = JSON.parse($('#orgs').text());
        if (this.endpoint.length && this.orgs.length) {
          this.fetchStats();
        }
      }
    }
  };
*/

  var searchDatasetsAsYouType = {

    buildResultsTable: function(results) {
      $('#dataset-list').html('');
      results.forEach(function(item) {
        var safeName = encodeURIComponent(item.name);
        var safeTitle = safeText(item.title);
        var findUrl = $('#find-url').text();
        var markup = '<tr><td><a href="'+findUrl+'/dataset/'+
          safeName + '">' + safeTitle +
          '</a></td><td>' +
          (item.published ? 'Published' : 'Draft') +
          '</td><td class="actions">' +
          '<a href="/dataset/' +
          safeName +
          '/addfile/">Add&nbsp;Data</a>' +
          '<a href="/dataset/edit/' +
          safeName +
          '">Edit</a></td></tr>';
        $('#dataset-list').append(markup);
      });
    },

    buildPagination: function($paginationSection, numResults, searchQuery) {
      $paginationSection.html('');
      if (numResults>20) {
        for (var i=1; i <= Math.ceil(numResults/20); i++) {
          $paginationSection.append(
            '<span><a href="?page='+i+'&amp;q='+searchQuery+'">' +
              i + '</a> </span>'
                );
        }
      }
    },

    changeSortLinks: function(searchQuery) {
      $('.sortable-heading').each(function() {
        var link =$(this).find('a');
        var hrefObj = splitUrl(link.attr('href'));
        hrefObj.params.q = searchQuery;
        link.attr('href', buildUrl(hrefObj));
      });
    },

    init: function() {
      var self = this;
      $('#filter-dataset-form #q').on('keyup', function(event) {
        if (event.which === 0 ||
            event.which === 9 || // tab
            event.which === 16 || // shift-tab
            event.ctrlKey ||
            event.metaKey ||
            event.altKey) {
          return;
        }
        var safeSearchQuery = encodeURIComponent(this.value);
        $.get('/api/datasets?q=' + this.value)
          .success(function(response) {
            var numResults = response.total;
            var $paginationSection = $('.pagination');

            if (numResults == 0) {
              $('.manage-data').hide();
              $('.noresults').show();
            } else {
              var searchResults = response.datasets;

              $('.manage-data').show();
              $('.noresults').hide();

              // rebuild the table with results
              self.buildResultsTable(searchResults);
              self.changeSortLinks(safeSearchQuery);
            }

            self.buildPagination(
              $paginationSection,
              numResults,
              safeSearchQuery
            );

          });
      });
    }
  };

  var analytics = {
    init: function() {
      if (!window.ga) return;
      $('[data-ga-action]').each(function(i, el) {
        var action = $(el).data('ga-action');
        if (action) {
          var actionParams = ['send', 'event', 'dataset'].concat(action.split(','));
          window.ga.apply(this, actionParams);
        }
      });
    }
  }

  $(document).ready(function() {
    showHide.init({ rowLimit: 5 });
    typeAhead.init({ selector: '.location-input' });
//    stats.init('#stats');
    searchDatasetsAsYouType.init('#filter-dataset-form');
    analytics.init();
  });

})();
