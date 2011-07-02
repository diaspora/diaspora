(function() {
  var NotificationDropdown = function() {
    var self = this;

    this.start = function() {
      this.badge = $("#notification_badge");
      this.badgeLink = this.badge.find("a");
      this.documentBody = $(document.body);
      this.dropdown = $("#notification_dropdown");
      this.dropdownNotifications = this.dropdown.find(".notifications");

      this.badgeLink.toggle(function(evt) {
          evt.preventDefault();
          evt.stopPropagation();
          
          self.getNotifications(function() { 
            self.badge.addClass("active");
            self.renderNotifications();
            self.dropdown.css("display", "block");
          });
        },  function(evt) {
          evt.preventDefault();
          evt.stopPropagation();

          self.badge.removeClass("active");
          self.dropdown.css("display", "none");
      });

      this.dropdown.click(function(evt) {
        evt.stopPropagation();
      });

      this.documentBody.click(function(evt) {
        if(self.dropdownShowing()) {
          self.badgeLink.click();
        }
      });
    };


    this.dropdownShowing = function() {
      return this.dropdown.css("display") === "block";
    };

    this.getNotifications = function(callback) {
      $.getJSON("/notifications", function(notifications) {
        self.notifications = notifications;
        callback.apply(self, []);
      });
    };

    this.renderNotifications = function() {
      self.dropdownNotifications.empty();

      $.each(self.notifications.notifications, function(index, notifications) {
        $.each(notifications, function(index, notification) {
          var notificationElement = $("<div/>")
            .addClass("notification_element")
            .html(notification.translation)
            .prepend($("<img/>", { src: notification.actors[0].avatar }))
            .append("<br />")
            .append($("<abbr/>", {
              "class": "timeago",
              "title": notification.created_at
            }))
            .appendTo(self.dropdownNotifications);

          Diaspora.widgets.timeago.updateTimeAgo(".notification_element time.timeago");

          if(notification.unread) {
            $.ajax({
              url: "/notifications/" + notification.id,
              type: "PUT",
              success: function() {
                Diaspora.widgets.notifications.decrementCount();
              }
            });
          }
        });
      });
    };
  };

  Diaspora.widgets.add("notificationDropdown", NotificationDropdown);
})();
