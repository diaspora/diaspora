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
      if(typeof this.collection[widgetId].start !== "undefined") {
        this.collection[widgetId].start();
      }
    };
    $("#notification_badge a").click(function(event){
      event.preventDefault();
      $.ajax({
        "url":"/notifications",
        "success":function(data){
          $("#notifications_overlay").show();
          var hash = eval("(" + data + ")");
          var notifications_element =  $("#notifications_overlay .notifications");
          var day_element_template = $("#notifications_overlay .day_group").clone();
          day_element_template.find(".notifications_for_day").empty();
          var stream_element_template = $("#notifications_overlay .stream_element").clone();
          notifications_element.empty();
          $.each(hash["group_days"], function(day){
            var day_element = day_element_template.clone();
            day_element.find(".month").text(day.split(" ")[0])
            day_element.find(".day").text(day.split(" ")[1])
            var notifications_for_day = hash["group_days"][day]
            var notifications_for_day_element = day_element.find('.notifications_for_day');
            $.each(notifications_for_day, function(i, notification_hash){
              $.each(notification_hash, function(notification_type, notification){
                var stream_element = stream_element_template.clone();
                console.log(notification_type);
                console.log(notification);
                stream_element.find(".actor").
                  text(notification["actors"][0]["name"]).
                  attr("href", notification["actors"][0]["url"]);
                console.log(notification["created_at"]);
                stream_element.find('time').text(notification["created_at"]);
                notifications_for_day_element.append(stream_element);
              });
            });
            notifications_element.append(day_element);
          })
        }
      });
    });
  };

  Diaspora.WidgetCollection.prototype.subscribe = function(id, callback, context) {
    this.eventsContainer.bind(id, $.proxy(callback, context));
  };

  Diaspora.WidgetCollection.prototype.publish = function(id) {
    this.eventsContainer.trigger(id);
  };

  Diaspora.widgets = new Diaspora.WidgetCollection();

  window.Diaspora = Diaspora;
})();


$(document).ready(function() { Diaspora.widgets.init(); });

