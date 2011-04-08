/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

var Diaspora = Diaspora || {};

Diaspora.widgetCollection = function() {
  this.initialized = false;
  this.collection = {};
};

Diaspora.widgetCollection.prototype.add = function(widgetId, widget) {
    this[widgetId] = this.collection[widgetId] = new widget();
    if(this.initialized) {
      this.collection[widgetId].start();
    }
  };

Diaspora.widgetCollection.prototype.remove = function(widgetId) {
    delete this.collection[widgetId];
};

Diaspora.widgetCollection.prototype.init = function() {
  this.initialized = true;
  for(var widgetId in this.collection) {
    this.collection[widgetId].start();
  }
}

Diaspora.widgets = Diaspora.widgets || new Diaspora.widgetCollection();

$(document).ready(function() {
  Diaspora.widgets.init();
});
