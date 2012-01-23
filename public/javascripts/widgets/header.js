(function() {
  var Header = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, header) {
      self.notifications = self.instantiate("Notifications",
        header.find("#notification_badge .badge_count"),
        header.find("#notification_dropdown")
      );

      self.notificationsDropdown = self.instantiate("NotificationsDropdown",
        header.find("#notification_badge"),
        header.find("#notification_dropdown")
      );

      self.search = self.instantiate("Search", header.find(".search_form"));
    });
  };

  Diaspora.Widgets.Header = Header;
})();
