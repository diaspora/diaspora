(function() {
  var FlashMessages = function() {
    var self = this;

    this.subscribe("widget/ready", function() {
      self.animateMessages();
    });

    this.animateMessages = function() {
      self.flashMessages().addClass("expose").delay(8000).fadeTo(200, 0.5);
    };

    this.render = function(result) {
      self.flashMessages().removeClass("expose").remove();

      $("<div/>", {
        id: result.success ? "flash_notice" : "flash_error"
      })
      .html($("<div/>", {
        'class': "message"
        })
        .text(result.notice))
      .prependTo(document.body);


      self.animateMessages();
    };

    this.flashMessages = function() {
      return $("#flash_notice, #flash_error, #flash_alert");
    };
  };

  Diaspora.Widgets.FlashMessages = FlashMessages;
})();
