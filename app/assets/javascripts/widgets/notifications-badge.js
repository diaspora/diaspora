// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

(function() {
  var NotificationDropdown = function() {
    var self = this;
    var currentPage = 2;
    var notificationsLoaded = 10;

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
        self.badge.on('click', self.badgeLink, function(evt){
          evt.preventDefault();
          evt.stopPropagation();
          if (self.dropdownShowing()){
            self.hideDropdown();
          } else {
            self.showDropdown();
          }
        });
      }

      self.documentBody.click(function(evt) {
        var inDropdown = $(evt.target).parents().is(self.dropdown);
        var inHovercard = $.contains(app.hovercard.el, evt.target);

        if(!inDropdown && !inHovercard && self.dropdownShowing()) {
          self.badgeLink.click();
        }
      });
    });


    this.dropdownShowing = function() {
      return this.dropdown.css("display") === "block";
    };

    this.showDropdown = function() {
      self.ajaxLoader.show();
      self.badge.addClass("active");
      self.dropdown.css("display", "block");
      self.dropdownNotifications.addClass("loading");
      self.getNotifications();

    };

    this.hideDropdown = function() {
      self.badge.removeClass("active");
      self.dropdown.css("display", "none");
      self.dropdownNotifications.perfectScrollbar('destroy');
    };

    this.getMoreNotifications = function(page) {
      $.getJSON("/notifications?per_page=5&page=" + page, function(notifications) {
        for(var i = 0; i < notifications.length; ++i)
          self.notifications.push(notifications[i]);
        notificationsLoaded += 5;
        self.renderNotifications();
      });
    };

    this.hideAjaxLoader = function(){
      self.ajaxLoader.find('img').fadeTo(200, 0, function(){
        self.ajaxLoader.hide(300, function(){
          self.ajaxLoader.find('img').css('opacity', 1);
        });
      });
    };

    this.getNotifications = function() {
      $.getJSON("/notifications?per_page="+notificationsLoaded, function(notifications) {
        self.notifications = notifications;
        self.renderNotifications();
      });
    };

    this.renderNotifications = function() {
      this.dropdownNotifications.find('.media.stream_element').remove();
      $.each(self.notifications, function(index, notifications) {
        $.each(notifications, function(index, notification) {
          if($.inArray(notification, notifications) === -1){
            var node = self.dropdownNotifications.append(notification.note_html);
            $(node).find(".unread-toggle .entypo").tooltip('destroy').tooltip();
          }
        });
      });

      self.hideAjaxLoader();

      app.helpers.timeago(self.dropdownNotifications);

      self.dropdownNotifications.perfectScrollbar('destroy').perfectScrollbar();
      var isLoading = false;
      self.dropdownNotifications.removeClass("loading");
      //Infinite Scrolling
      self.dropdownNotifications.scroll(function() {
        var bottom = self.dropdownNotifications.prop('scrollHeight') - self.dropdownNotifications.height();
        var currentPosition = self.dropdownNotifications.scrollTop();
        isLoading = ($('.loading').length === 1);
        if (currentPosition + 50 >= bottom && notificationsLoaded <= self.notifications.length && !isLoading) {
            self.dropdownNotifications.addClass("loading");
            self.getMoreNotifications(++currentPage);
        }
      });
    };
  };

  Diaspora.Widgets.NotificationsDropdown = NotificationDropdown;
})();
// @license-end
