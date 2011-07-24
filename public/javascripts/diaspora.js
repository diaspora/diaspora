/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  if(typeof window.Diaspora !== "undefined") {
    return;
  }

  var Diaspora = { };

  Diaspora.EventBroker = {
    extend: function(obj) {
      obj.eventsContainer = $({});

      obj.subscribe = Diaspora.EventBroker.subscribe;
      obj.publish = Diaspora.EventBroker.publish;

      obj.publish = $.proxy(function(eventId, args) {
        this.eventsContainer.trigger(eventId, args);
      }, obj);

      obj.subscribe = $.proxy(function(eventIds, callback, context) {
	      var eventIds = eventIds.split(" ");
            
	      for(var eventId in eventIds) {
	        this.eventsContainer.bind(eventIds[eventId], $.proxy(callback, context));
	      }
      }, obj);

      return obj;
    }
  };

  Diaspora.widgets = {
    initialize: false,
    collection: {},
    constructors: {},

    initialize: function() {
      this.initialized = true;
      Diaspora.EventBroker.extend(this);

      for(var widgetId in this.collection) {
        this.collection[widgetId].publish("widget/ready");
      }
    },

    add: function(widgetId, Widget) {
      $.extend(Widget.prototype, Diaspora.EventBroker.extend({}));

      this[widgetId] = this.collection[widgetId] = new Widget();
      if(this.initialized) {
        this.collection[widgetId].publish("widget/ready");
      }
    },

    get: function(widgetId) {
      return this.collection[widgetId];
    },

    remove: function(widgetId) {
      delete this.collection[widgetId];
    }
  };

  window.Diaspora = Diaspora;
})();


$(function() {
  Diaspora.widgets.initialize();
});
