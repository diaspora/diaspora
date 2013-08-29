
/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

(function() {
  var Notifications = function() {
    var self = this;
    
    this.subscribe("widget/ready", function(evt, badge, notificationMenu) {
      $.extend(self, {
        badge: badge,
        count: parseInt(badge.html()) || 0,
        notificationArea: null,
        notificationMenu: notificationMenu
      });

      $("a.more").click( function(evt) {
        evt.preventDefault();
        $(this).hide()
          .next(".hidden")
          .removeClass("hidden");
      });
      self.notificationMenu.find('a#mark_all_read_link').click(function(event) {
        $.ajax({
          url: "/notifications/read_all",
          type: "GET",
          dataType:'json',
          success: function(){
            self.notificationMenu.find('.unread').each(function(index) {
              self.setUpRead( $(this) );
            });
            if ( self.notificationArea ) {
              self.notificationArea.find('.unread').each(function(index) {
                self.setUpRead( $(this) );
              });
            }
            self.resetCount();
          }
        });
        $(event.target).addClass("disabled");
        return false;
      });
    });
    this.setUpNotificationPage = function( contentArea ) {
      self.notificationArea = contentArea;
      contentArea.find(".unread,.read").each(function(index) {
        if ( $(this).hasClass("unread") ) {
          self.setUpUnread( $(this) );
        } else {
          self.setUpRead( $(this) );
        }
      });
    }
    this.unreadClick = function() {
      $.ajax({
        url: "/notifications/" + $(this).closest(".stream_element,.notification_element").data("guid"),
        data: { set_unread: true },
        type: "PUT",
        success: self.clickSuccess
      });
    };
    this.readClick = function() {
      $.ajax({
        url: "/notifications/" + $(this).data("guid"),
        data: { set_unread: false },
        type: "PUT",
        success: self.clickSuccess
      });
    };
    this.setUpUnread = function( an_obj ) {
      an_obj.removeClass("read").addClass( "unread" );
      an_obj.find('.unread-setter').hide();
      an_obj.find('.unread-setter').unbind("click");
      an_obj.unbind( "mouseenter mouseleave" );
      an_obj.click(self.readClick);
    }
    this.setUpRead = function( an_obj ) {
      an_obj.removeClass("unread").addClass( "read" );
      an_obj.unbind( "click" );
      an_obj.find(".unread-setter").click(Diaspora.page.header.notifications.unreadClick);
      an_obj.hover(
        function () {
          $(this).find(".unread-setter").show();
        },
        function () {
          $(this).find(".unread-setter").hide();
        }
      );
    }
    this.clickSuccess = function( data ) {
      var itemID = data["guid"]
      var isUnread = data["unread"]
      if ( isUnread ) {
        self.incrementCount();
      }else{
        self.decrementCount();
      }
      self.notificationMenu.find('.read,.unread').each(function(index) {
        if ( $(this).data("guid") == itemID ) {
          if ( isUnread ) {
            self.setUpUnread( $(this) )
          } else {
            self.setUpRead( $(this) )
          }
        }
      });
      if ( self.notificationArea ) {
        self.notificationArea.find('.read,.unread').each(function(index) {
          if ( $(this).data("guid") == itemID ) {
            if ( isUnread ) {
              self.setUpUnread( $(this) )
            } else {
              self.setUpRead( $(this) )
            }
          }
        });
      }
    };
    this.showNotification = function(notification) {
      $(notification.html).prependTo(this.notificationMenu)
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
      self.count = Math.max( self.count + change, 0 )
      self.badge.text(self.count);
      if ( self.notificationArea )
        self.notificationArea.find( ".notification_count" ).text(self.count);

      if(self.count === 0) {
        self.badge.addClass("hidden");
        if ( self.notificationArea )
          self.notificationArea.find( ".notification_count" ).removeClass("unread");
      }
      else if(self.count === 1) {
        self.badge.removeClass("hidden");
        if ( self.notificationArea )
          self.notificationArea.find( ".notification_count" ).addClass("unread");
      }
    };
    this.resetCount = function(change) {
      self.count = 0;
      this.changeNotificationCount(0);
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
