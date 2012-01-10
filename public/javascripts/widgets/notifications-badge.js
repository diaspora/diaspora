(function() {
  var NotificationDropdown = function() {
    var self = this;

    this.subscribe("widget/ready",function(evt, badge, dropdown) {
      $.extend(self, {
        badge: badge,
        badgeLink: badge.find("a"),
        documentBody: $(document.body),
        dropdown: dropdown,
        dropdownNotifications: dropdown.find(".notifications"),
        ajaxLoader: dropdown.find(".ajax_loader")
      });

      if( ! $.browser.msie ) {
        self.badgeLink.toggle(self.showDropdown, self.hideDropdown);
      }

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

    this.showDropdown = function(evt) {
      evt.preventDefault();

      self.ajaxLoader.show();
      self.badge.addClass("active");
      self.dropdown.css("display", "block");

      self.getNotifications();
    };

    this.hideDropdown = function(evt) {
      evt.preventDefault();

      self.badge.removeClass("active");
      self.dropdown.css("display", "none");
    };

    this.getNotifications = function() {
      $.getJSON("/notifications?per_page=5", function(notifications) {
        self.notifications = notifications;
        self.renderNotifications();
      });
    };

    this.renderNotifications = function() {
      self.dropdownNotifications.empty();

      $.each(self.notifications.notifications, function(index, notifications) {
        $.each(notifications, function(index, notification) {
          var notificationElement = $("<div/>")
            .addClass("notification_element")
            .data( "guid", notification.id )
            .html(notification.translation)
            .prepend($("<img/>", { src: notification.actors[0].avatar }))
            .append("<br />")
            .append($("<abbr/>", {
              "class": "timeago",
              "title": notification.created_at
            }))
            .appendTo(self.dropdownNotifications);

          notificationElement.find("abbr.timeago").timeago();
          notificationElement.click(Diaspora.page.header.notifications.messageClick);

          if(notification.unread) {
            notificationElement.addClass("unread");
            $.ajax({
              url: "/notifications/" + notification.id,
              type: "PUT",
              data: { unread: false },
              success: Diaspora.page.header.notifications.clickSuccess
            });
          } else {
            notificationElement.addClass("read");
          }
        });
      });

      self.ajaxLoader.hide();
    };
  };

  Diaspora.Widgets.NotificationsDropdown = NotificationDropdown;
})();
