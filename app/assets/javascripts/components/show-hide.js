var showHide = {
  selector: '.show-hide',

  init: function(params) {
    var that = this;
    console.log(this)
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


$(document).ready(function() {
  showHide.init({ rowLimit: 5 });
});
