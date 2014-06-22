
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
        notificationMenu: notificationMenu,
        notificationPage: null
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
            self.resetCount();
          }
        });
        $(event.target).addClass("disabled");
        return false;
      });
    });
    this.setUpNotificationPage = function( page ) {
      self.notificationPage = page;
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
        url: "/notifications/" + $(this).closest(".stream_element,.notification_element").data("guid"),
        data: { set_unread: false },
        type: "PUT",
        success: self.clickSuccess
      });
    };
    this.setUpUnread = function( an_obj ) {
      an_obj.removeClass("read").addClass( "unread" );
      an_obj.find('.unread-toggle')
        .unbind("click")
        .click(self.readClick)
        .find('.entypo')
        .tooltip('destroy')
        .removeAttr('data-original-title')
        .attr('title', Diaspora.I18n.t('notifications.mark_read'))
        .tooltip();
    }
    this.setUpRead = function( an_obj ) {
      an_obj.removeClass("unread").addClass( "read" );
      an_obj.find('.unread-toggle')
        .unbind("click")
        .click(self.unreadClick)
        .find('.entypo')
        .tooltip('destroy')
        .removeAttr('data-original-title')
        .attr('title', Diaspora.I18n.t('notifications.mark_unread'))
        .tooltip();
    }
    this.clickSuccess = function( data ) {
      var itemID = data["guid"]
      var isUnread = data["unread"]
      self.notificationMenu.find('.read,.unread').each(function(index) {
        if ( $(this).data("guid") == itemID ) {
          if ( isUnread ) {
            self.notificationMenu.find('a#mark_all_read_link').removeClass('disabled')
            self.setUpUnread( $(this) )
          } else {
            self.setUpRead( $(this) )
          }
        }
      });
      if ( self.notificationPage == null ) {
        if ( isUnread ) {
          self.incrementCount();
        }else{
          self.decrementCount();
        }
      } else {
        var type = $('.notification_element[data-guid=' + data["guid"] + ']').data('type');
        self.notificationPage.updateView(data["guid"], type, isUnread);
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

      if(self.count === 0) {
        self.badge.addClass("hidden");
      }
      else if(self.count === 1) {
        self.badge.removeClass("hidden");
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
