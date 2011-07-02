(function() {
  var NotificationDropdown = function() {
    this.start = function() {
      this.badge = $("#notification_badge a");
      this.documentBody = $(document.body);
      this.dropdown = $("#notification_dropdown");

      this.badge.click($.proxy(function(evt) {
        evt.preventDefault();
        evt.stopPropagation();

        if(!this.dropdownShowing()) {
          this.getNotifications(function() {
            this.toggleDropdown();
          });
        }
        else {
          this.toggleDropdown();
        }
      }, this));

      this.documentBody.click($.proxy(function(evt) {
        if(this.dropdownShowing()) {
          this.toggleDropdown(evt);
        }
      }, this));
    };
  };

  NotificationDropdown.prototype.dropdownShowing = function() {
    return this.dropdown.css("display") === "block";
  }

  NotificationDropdown.prototype.toggleDropdown = function() {
    if(!this.dropdownShowing()) {
      this.renderNotifications();
      this.showDropdown();
    } else {
      this.hideDropdown();
    }
  }

  NotificationDropdown.prototype.showDropdown = function() {
    this.badge.parent().addClass("active");
    this.dropdown.css("display", "block");
  }

  NotificationDropdown.prototype.hideDropdown = function() {
    this.badge.parent().removeClass("active");
    this.dropdown.css("display", "none");
  }

  NotificationDropdown.prototype.getNotifications = function(callback) {
    $.getJSON("/notifications", $.proxy(function(notifications) {
      this.notifications = notifications;
      callback.apply(this, [notifications]);
    }, this));
  };

  NotificationDropdown.prototype.renderNotifications = function() {
    this.dropdown.find(".notifications").html("");

    $.each(this.notifications.notifications, $.proxy(function(index, notifications) {
      $.each(notifications, $.proxy(function(index, notification) {
          $("<div/>", {
            "class": "notification_element"
          })
            .html(notification.translation)
            .prepend($("<img/>", { src: notification.actors[0].avatar }))
            .prependTo(this.dropdown.find(".notifications"));
      }, this));
    }, this));
  };

  Diaspora.widgets.add("notificationDropdown", NotificationDropdown);
})();
