/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  if(typeof window.Diaspora !== "undefined") {
    return;
  }

  var Diaspora = { };

  Diaspora.WidgetCollection = function() {
    this.initialized = false;
    this.collection = { };
    this.eventsContainer = $({});
  };

  Diaspora.WidgetCollection.prototype.add = function(widgetId, widget) {
    this[widgetId] = this.collection[widgetId] = new widget();
    if(this.initialized) {
      this.collection[widgetId].start();
    }
  };

  Diaspora.WidgetCollection.prototype.remove = function(widgetId) {
    delete this.collection[widgetId];
  };

  Diaspora.WidgetCollection.prototype.init = function() {
    this.initialized = true;
    
    for(var widgetId in this.collection) {
      if(this.collection[widgetId].hasOwnProperty("start")) {
        this.collection[widgetId].start();
      }
    }
  };

  Diaspora.WidgetCollection.prototype.subscribe = function(id, callback) {
    this.eventsContainer.bind(id, callback);
  };

  Diaspora.WidgetCollection.prototype.publish = function(id) {
    this.eventsContainer.trigger(id);
  };

  Diaspora.widgets = new Diaspora.WidgetCollection();
  
  window.Diaspora = Diaspora;
})();


$(document).ready(Diaspora.widgets.init);

