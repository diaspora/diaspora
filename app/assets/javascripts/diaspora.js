/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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
      $.extend(Diaspora.Widgets[Widget].prototype, Diaspora.EventBroker.extend(Diaspora.BaseWidget));

      var widget = new Diaspora.Widgets[Widget](),
        args = Array.prototype.slice.call(arguments, 1);

      widget.publish("widget/ready", args);

      return widget;
    },

    globalSubscribe: function(eventName, callback, context) {
      Diaspora.page.subscribe(eventName, callback, context);
    },

    globalPublish: function(eventName, args) {
      Diaspora.page.publish(eventName, args);
    }
  };

  Diaspora.BasePage = function(body) {
    $.extend(this, Diaspora.BaseWidget);
    $.extend(this, {
      backToTop: this.instantiate("BackToTop", body.find("#back-to-top")),
      directionDetector: this.instantiate("DirectionDetector"),
      events: function() { return Diaspora.page.eventsContainer.data("events"); },
      flashMessages: this.instantiate("FlashMessages"),
      header: this.instantiate("Header", body.find("header")),
      timeAgo: this.instantiate("TimeAgo")
    });
  };

  Diaspora.instantiatePage = function() {
    if (typeof Diaspora.Pages[Diaspora.Page] === "undefined") {
      Diaspora.page = Diaspora.EventBroker.extend(Diaspora.BaseWidget);
    } else {
      var Page = Diaspora.Pages[Diaspora.Page];
      $.extend(Page.prototype, Diaspora.EventBroker.extend(Diaspora.BaseWidget));

      Diaspora.page = new Page();
    }

    if(!$.mobile)//why does this need this?
      $.extend(Diaspora.page, new Diaspora.BasePage($(document.body)));
    Diaspora.page.publish("page/ready", [$(document.body)])
  };

  // temp hack to check if backbone is enabled for the page
  Diaspora.backboneEnabled = function(){
    return window.app && window.app.stream !== undefined;
  }

  window.Diaspora = Diaspora;
})();


$(Diaspora.instantiatePage);
