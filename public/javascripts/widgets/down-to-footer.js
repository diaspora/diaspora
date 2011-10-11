(function() {
  var DownToFooter = function() {
    var self = this;
    this.subscribe("widget/ready", function(evt, button) {
      $.extend(self, {
        button: button,
        body: $("html, body"),
        window: $(window),
      });

      self.button.click(self.downToFooter);
      self.window.debounce("scroll", self.toggleVisibility, 250);
      self.toggleVisibility();
    });

    this.downToFooter = function(evt) {
      evt.preventDefault();
      self.window.infinitescroll("pause");
      self.body.animate({scrollTop: self.body.height()});
    };

    this.toggleVisibility = function() {
        self.button.animate({
        zIndex: (self.body.scrollTop() == 0)
          ? 50
          : 48 ,
        opacity: (self.body.scrollTop() == 0)
          ? 0.3
          : 0
      });
    };
  };

  Diaspora.Widgets.DownToFooter = DownToFooter;
})();
