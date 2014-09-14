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

      self.getNotifications();
    };

    this.hideDropdown = function() {
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

      $.each(self.notifications, function(index, notifications) {
        $.each(notifications, function(index, notification) {
          self.dropdownNotifications.append(notification.note_html);
        });
      });
      self.dropdownNotifications.find("time.timeago").timeago();

      self.dropdownNotifications.find('.unread').each(function(index) {
        Diaspora.page.header.notifications.setUpUnread( $(this) );
      });
      self.dropdownNotifications.find('.read').each(function(index) {
        Diaspora.page.header.notifications.setUpRead( $(this) );
      });
      self.ajaxLoader.hide();
    };
  };

  Diaspora.Widgets.NotificationsDropdown = NotificationDropdown;
})();
