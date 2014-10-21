// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
// @license-end

