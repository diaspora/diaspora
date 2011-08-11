(function() {
  var UserDropdown = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, menuElement) {
      $.extend(self, {
        menuElement: menuElement
      });

      self.menuElement.click(self.toggleDropdown);
      self.menuElement.find("li a").slice(1, 3).click(function(evt) { evt.stopPropagation(); });
      $(document.body).click(self.hideDropdown);
    });

    this.toggleDropdown = function(evt) {
      evt.preventDefault();
      evt.stopPropagation();

      self.menuElement.toggleClass("active");
    };

    this.hideDropdown = function() {
      if(self.menuElement.hasClass("active") && !$(this).parents("#user_menu").length) {
        self.menuElement.removeClass("active");
      }
    };
  };

  Diaspora.Widgets.UserDropdown = UserDropdown;
})();