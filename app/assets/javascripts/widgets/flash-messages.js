(function() {
  var FlashMessages = function() {
    var self = this;

    this.subscribe("widget/ready", function() {
      self.animateMessages();
    });

    this.animateMessages = function() {
      var flashMessages = $("#flash_notice, #flash_error, #flash_alert");
      flashMessages.addClass("expose");
      flashMessages.delay(8000);
			flashMessages.fadeTo(200, 0.5);
    };

    this.render = function(result) {
      $("<div/>", {
        id: result.success ? "flash_notice" : "flash_error"
      })
      .html($("<div/>", {
        'class': "message"
        })
        .html(result.notice))
      .prependTo(document.body);

      self.animateMessages();
    };
  };

  Diaspora.Widgets.FlashMessages = FlashMessages;
})();
