// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
            if(eventNames.hasOwnProperty(eventName)) {
              this.eventsContainer.trigger(eventNames[eventName], args);
            }
          }
        },
        subscribe: function(eventName, callback, context) {
          var eventNames = eventName.split(" ");

          for(eventName in eventNames) {
            if(eventNames.hasOwnProperty(eventName)) {
              this.eventsContainer.bind(eventNames[eventName], $.proxy(callback, context));
            }
          }
        }
      });

      return whatToExtend;
    }
  };

  Diaspora.BaseWidget = {
    instantiate: function(Widget) {
      // Mobile version loads only some widgets
      if (typeof Diaspora.Widgets[Widget] === 'undefined') return;

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
      directionDetector: this.instantiate("DirectionDetector"),
      events: function() { return Diaspora.page.eventsContainer.data("events"); },
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

    if(!$.mobile) // why does this need this?
      $.extend(Diaspora.page, new Diaspora.BasePage($(document.body)));
    Diaspora.page.publish("page/ready", [$(document.body)]);
  };

  window.Diaspora = Diaspora;
})();

$(Diaspora.instantiatePage);
// @license-end
