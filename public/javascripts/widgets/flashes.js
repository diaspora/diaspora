(function() {
  var Flashes = function() {
    var self = this;

    this.subscribe("widget/ready", function() {
      self.animateMessages();
    });

    this.animateMessages = function() {
      var flashMessages = $("#flash_notice, #flash_error, #flash_alert");
      flashMessages.animate({
        top: 0
      }).delay(2000).animate({
        top: -100
      }, flashMessages.remove);
    };

    this.render = function(result) {
      $("<div/>", {
				id: (result.success) ? "flash_notice" : "flash_error"
      })
      	.prependTo(document.body)
      	.html(result.notice);

      self.animateMessages();
    };
  };

  Diaspora.widgets.add("flashes", Flashes);
})();
