(function() {
  var NotificationDropdown = function() {
    var self = this;

    this.subscribe("widget/ready",function() {
      self.badge = $("#notification_badge");
      self.badgeLink = self.badge.find("a");
      self.documentBody = $(document.body);
      self.dropdown = $("#notification_dropdown");
      self.dropdownNotifications = self.dropdown.find(".notifications");
      self.ajaxLoader = self.dropdown.find(".ajax_loader");

      self.badgeLink.toggle(function(evt) {
	  evt.preventDefault();
          evt.stopPropagation();

          self.ajaxLoader.show();
          self.badge.addClass("active");
          self.dropdown.css("display", "block");

          self.getNotifications(function() {
            self.renderNotifications();
          });
        },  function(evt) {
          evt.preventDefault();
          evt.stopPropagation();

          self.badge.removeClass("active");
          self.dropdown.css("display", "none");
      });

      self.dropdown.click(function(evt) {
        evt.stopPropagation();
      });

      self.documentBody.click(function(evt) {
        if(self.dropdownShowing()) {
          self.badgeLink.click();
        }
      });
    });


    this.dropdownShowing = function() {
      return this.dropdown.css("display") === "block";
    };

    this.getNotifications = function(callback) {
      $.getJSON("/notifications?per_page=5", function(notifications) {
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
            notificationElement.addClass("unread");
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


      self.ajaxLoader.hide();
    };
  };

  Diaspora.widgets.add("notificationDropdown", NotificationDropdown);
})();
