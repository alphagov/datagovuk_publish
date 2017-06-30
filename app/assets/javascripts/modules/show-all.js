var showAll = {}

showAll._selector = '.show-all';

showAll._callback = function (event) {
  var itemSelector = showAll._selector + '__item';
  var a = $(this)
  var rows = $(this).parents(showAll._selector).first().find(itemSelector)
  a.toggleClass(itemSelector + '__expanded')
  if (a.hasClass(itemSelector + '__expanded')) {
    a.text('Close')
    rows.show()
  } else {
    a.text('Show all')
    rows.each(function (i) {
      if ($(this).index() >= event.data.rowLimit) $(this).hide()
    })
  }
}

showAll.init = function (params) {
  $.each($(this._selector), function (index, show) {
    var rows = $(show).find(showAll._selector + '__item')
    rows.each(function () {
      if ($(this).index() >= params.rowLimit) {
        $(this).hide()
      }
    })
    if (rows.length > params.rowLimit) {
      $(show).find(showAll._selector + '__toggle')
        .on('click', params, showAll._callback)
        .show()
    }
  })
}
