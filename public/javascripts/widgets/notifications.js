
/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var Notifications = function() {
    var self = this;
    
    this.subscribe("widget/ready", function(evt, notificationArea, badge) {
      $.extend(self, {
        badge: badge,
        count: parseInt(badge.html()) || 0,
        notificationArea: notificationArea
      });

      $(".stream_element.unread").live("mousedown", function() {
        self.decrementCount();

        $.ajax({
          url: "notifications/" + $(this).removeClass("unread").data("guid"),
          type: "PUT"
        });
      });

      $("a.more").live("click", function(evt) {
        evt.preventDefault();
        $(this).hide()
          .next(".hidden")
          .removeClass("hidden");
      });
    });
    
    this.showNotification = function(notification) {
      // If browser supports webkitNotifications and we have permissions to show those.
      if( window.webkitNotifications && window.webkitNotifications.checkPermission() == 0 ) {
        window.webkitNotifications.createNotification(
          $(notification.html).children("img").attr('src'), // Icon
          "DIASPORA*", // Headline
          $(notification.html).text() // Body
        ).show();
      }
      else {
        // If browser doesn't support webkitNotifications at all, or we currently don't have permissions
        $(notification.html).prependTo(this.notificationArea)
          .fadeIn(200)
          .delay(8000)
          .fadeOut(200, function() {
          $(this).detach();
        });
      }


      if(typeof notification.incrementCount === "undefined" || notification.incrementCount) {
        this.incrementCount();
      }
    };

    this.changeNotificationCount = function(change) {
      self.count += change;

      if(self.badge.text() !== "") {
				self.badge.text(self.count);

				if(self.count === 0) {
	  			self.badge.addClass("hidden");
				}
				else if(self.count === 1) {
	  			self.badge.removeClass("hidden");
				}
      }
    };

    this.decrementCount = function() {
      self.changeNotificationCount(-1);
    };

    this.incrementCount = function() {
      self.changeNotificationCount(1);
    };
  };

  Diaspora.Widgets.Notifications = Notifications;
})();