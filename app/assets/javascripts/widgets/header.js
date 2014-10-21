// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
// @license-end

