/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var Notifications = function() {
    var self = this;
    
    this.subscribe("widget/ready", function() {
      self.badge = $("#notification_badge .badge_count")
      self.indexBadge =  $(".notification_count");
      self.onIndexPage = self.indexBadge.length > 0;
      self.notificationArea = $("#notifications");
      self.count = parseInt(self.badge.html()) || 0;

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
    });
    
    this.showNotification = function(notification) {
      $(notification.html).prependTo(this.notificationArea)
	.fadeIn(200)
	.delay(8000)
	.fadeOut(200, function() {
	  $(this).detach();
	});

      if(typeof notification.incrementCount === "undefined" || notification.incrementCount) {
	this.incrementCount();
      }
    };

    this.changeNotificationCount = function(change) {
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

    this.decrementCount = function() {
      self.changeNotificationCount(-1);
    };

    this.incrementCount = function() {
      self.changeNotificationCount(1);
    };
  };

  Diaspora.widgets.add("notifications", Notifications);
})();
