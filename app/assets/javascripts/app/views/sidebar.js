app.views.Sidebar = app.views.Base.extend({
  el: '.rightBar',

  events: {
    'click input#invite_code': 'selectInputText'
  },

  selectInputText: function(event) {
    event.target.select();
  }
});
