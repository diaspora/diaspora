/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

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