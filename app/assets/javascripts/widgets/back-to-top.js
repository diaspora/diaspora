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

      var throttledScroll = _.throttle($.proxy(self.toggleVisibility, self), 250);
      self.window.scroll(throttledScroll);
    });

    this.backToTop = function(evt) {
      evt.preventDefault();
      self.body.animate({scrollTop: 0});
    };

    this.toggleVisibility = function() {
      self.button[
        (self.body.scrollTop() > 1000) ?
          'addClass' :
          'removeClass'
      ]('visible')
    };
  };

  Diaspora.Widgets.BackToTop = BackToTop;
})();
