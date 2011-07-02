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
            self.renderNotifications();
            self.dropdown.css("display", "block");
          });
        },  function(evt) {
          evt.preventDefault();
          evt.stopPropagation();

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
          $("<div/>")
            .addClass("notification_element")
            .addClass((notification.unread) ? "unread" : "read" )
            .html(notification.translation)
            .prepend($("<img/>", { src: notification.actors[0].avatar }))
            .prependTo(self.dropdownNotifications);
        });
      });
    };
  };

  Diaspora.widgets.add("notificationDropdown", NotificationDropdown);
})();
