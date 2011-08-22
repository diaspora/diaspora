/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var Diaspora = {
    Pages: {},
    Widgets: {}
  };

  Diaspora.EventBroker = {
    extend: function(Klass) {
      var whatToExtend = (typeof Klass === "function") ? Klass.prototype : Klass;

      $.extend(whatToExtend, {
	      eventsContainer: $({}),
        publish: function(eventName, args) {
          var eventNames = eventName.split(" ");

          for(eventName in eventNames) {
            this.eventsContainer.trigger(eventNames[eventName], args);
          }
        },
        subscribe: function(eventName, callback, context) {
          var eventNames = eventName.split(" ");

          for(eventName in eventNames) {
            this.eventsContainer.bind(eventNames[eventName], $.proxy(callback, context));
          }
        }
      });

      return whatToExtend;
    }
  };

  Diaspora.BaseWidget = {
    instantiate: function(Widget, element) {
      if(typeof Diaspora.Widgets[Widget] === "undefined") { throw new Error("Widget " + Widget + " does not exist"); }
     
      $.extend(Diaspora.Widgets[Widget].prototype, Diaspora.EventBroker.extend(Diaspora.BaseWidget));

      var widget = new Diaspora.Widgets[Widget](),
        args = Array.prototype.slice.call(arguments, 1);

      widget.publish("widget/ready", args);

      return widget;
    },

    globalSubscribe: function(eventName, callback, context) {
      if(typeof callback === "undefined") { throw new Error("Callback must be defined for event: " + eventName); }
      Diaspora.page.subscribe(eventName, callback, context);
    },  

    globalPublish: function(eventName, args) {
      Diaspora.page.publish(eventName, args);
    }
  };

  window.Diaspora = Diaspora;
})();


$(function() {
  if (typeof Diaspora.Pages[Diaspora.Page] === "undefined") {
    Diaspora.page = Diaspora.EventBroker.extend(Diaspora.BaseWidget);
    return;
  }

  var Page = Diaspora.Pages[Diaspora.Page];
  $.extend(Page.prototype, Diaspora.EventBroker.extend(Diaspora.BaseWidget));

  Diaspora.page = new Page();
  Diaspora.page.publish("page/ready", [$(document.body)])
});