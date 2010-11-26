var Diaspora = Diaspora || {};
Diaspora.widgets = Diaspora.widgets || {
  pageWidgets: {},
  
  add: function(widgetId, widget) {
    this.pageWidgets[widgetId] = widget;
  },

  remove: function(widgetId) {
    delete this.pageWidgets[widgetId];
  },

  init: function() {
    for (var widgetId in this.pageWidgets) {
      this.pageWidgets[widgetId].start();
    }
  }
};