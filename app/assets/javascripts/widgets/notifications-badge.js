// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

(function() {
  var NotificationDropdown = function() {
    var self = this;
    var currentPage = 2;
    var notificationsLoaded = 10;
    var isLoading = false;

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
      $('.notifications').addClass("loading");
      self.getNotifications();
      
    };

    this.hideDropdown = function() {
      self.badge.removeClass("active");
      self.dropdown.css("display", "none");
      $('.notifications').perfectScrollbar('destroy');
    };

    this.getMoreNotifications = function() {
      $.getJSON("/notifications?per_page=5&page="+currentPage, function(notifications) {
        for(var i = 0; i < notifications.length; ++i)
          self.notifications.push(notifications[i]);
        notificationsLoaded += 5;
        self.renderNotifications();
      });
    };

    this.getNotifications = function() {
      $.getJSON("/notifications?per_page="+notificationsLoaded, function(notifications) {
        self.notifications = notifications;
        self.renderNotifications();
      });
    };

    this.renderNotifications = function() {
      self.dropdownNotifications.empty();
      $.each(self.notifications, function(index, notifications) {
        $.each(notifications, function(index, notification) {
          if($.inArray(notification, notifications) === -1)
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
      $('.notifications').perfectScrollbar('destroy');
      $('.notifications').perfectScrollbar();
      self.ajaxLoader.hide();
      isLoading = false;
      $('.notifications').removeClass("loading");
      //Infinite Scrolling
      $('.notifications').scroll(function(e) {
        var bottom = $('.notifications').prop('scrollHeight') - $('.notifications').height();
        var currentPosition = $('.notifications').scrollTop();
        isLoading = ($('.loading').length == 1);
        if (currentPosition + 50 >= bottom && notificationsLoaded <= self.notifications.length && !isLoading) {
            $('.notifications').addClass("loading");
            ++currentPage;
            self.getMoreNotifications();
        }
      });
    };
  };

  Diaspora.Widgets.NotificationsDropdown = NotificationDropdown;
})();
// @license-end

