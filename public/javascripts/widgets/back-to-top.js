(function() {
  var BackToTop = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, button) {
      $.extend(self, {
        button: button,
        body: $("html, body"),
        window: $(window)
      });

      self.button.click(self.backToTop);
      var debouncedScroll = _.debounce(self.toggleVisibility, 250);
      $(window).scroll(debouncedScroll)
    });

    this.backToTop = function(evt) {
      evt.preventDefault();

      self.body.animate({scrollTop: 0});
    };

    this.toggleVisibility = function() {
      self.button.animate({
        opacity: (self.body.scrollTop() > 1000)
          ? 0.5
          : 0
      });
    };
  };

  Diaspora.Widgets.BackToTop = BackToTop;
})();
