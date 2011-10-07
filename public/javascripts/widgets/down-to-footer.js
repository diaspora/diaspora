(function() {
  var DownToFooter = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, button) {
      $.extend(self, {
        button: button,
        body: $("html, body"),
        window: $(window)
      });

      self.button.click(self.downToFooter);
      self.window.debounce("scroll", self.toggleVisibility, 250);
    });

    this.downToFooter = function(evt) {
      evt.preventDefault();

      self.body.animate({scrollBottom: 30000});
    };

    this.toggleVisibility = function() {
      self.button.animate({
        opacity: (self.body.scrollTop() < 100)
          ? 0.2
          : 0
      });
    };
  };

  Diaspora.Widgets.DownToFooter = DownToFooter;
})();
