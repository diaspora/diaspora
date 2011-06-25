/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var Notifications = function() {
    this.start = function() {
      var self = this;
      this.badge = $("#notification_badge .badge_count")
      this.index_badge =  $(".notification_count");
      this.on_index_page = this.index_badge.length > 0
      this.notificationArea = $("#notifications");
      this.count = parseInt(this.badge.html()) || 0;

      $(".stream_element.unread").live("mousedown", function() {
        self.decrementCount();

        var notification = $(this);
        notification.removeClass("unread");
        
        $.ajax({
          url: "notifications/" + notification.data("guid"),
          type: "PUT"
        });
      });

      $("a.more").live("click", function(evt) {
        evt.preventDefault();
        $(this).hide()
          .next(".hidden")
          .removeClass("hidden");
      });
    };
  };

  Notifications.prototype.showNotification = function(notification) {
	// If browser supports webkitNotifications and we have permissions to show those.
	if( window.webkitNotifications && window.webkitNotifications.checkPermission() !== 0 ) {
		window.webkitNotifications.createNotification(
			$(notification.html).children("img"), // Icon
			"DIASPORA*", // Headline
			$(notification.html).text() // Body
		).show();
	}
	else {
		// If browser supports webkitNotifications, but we don't have the permissions to show those... yet!
		if( window.webkitNotifications ) {
			window.webkitNotifications.requestPermission();
		}
		
		// If browser doesn't support webkitNotifications at all.
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

  Notifications.prototype.changeNotificationCount = function(change) {
    this.count += change;

    if(this.badge.text() !== "") {
      this.badge.text(this.count);
      if(this.on_index_page)
        this.index_badge.text(this.count + " ");

      if(this.count === 0) {
        this.badge.addClass("hidden");
        if(this.on_index_page)
          this.index_badge.removeClass('unread');
      }
      else if(this.count === 1) {
        this.badge.removeClass("hidden");
      }
    }
  };

  Notifications.prototype.decrementCount = function() {
    this.changeNotificationCount(-1);
  };

  Notifications.prototype.incrementCount = function() {
    this.changeNotificationCount(1);
  };

  Diaspora.widgets.add("notifications", Notifications);
})();