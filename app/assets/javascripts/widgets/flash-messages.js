(function() {
  var FlashMessages = function() {
    var self = this;

    this.subscribe("widget/ready", function() {
      self.animateMessages();
    });

    this.animateMessages = function() {
      var flashMessages = $("#flash_notice, #flash_error, #flash_alert");
      flashMessages.animate({
        top: 0
      }, 400).delay(4000).animate({
        top: -100
      }, 400, function(){
        $(this).remove();
      });
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
