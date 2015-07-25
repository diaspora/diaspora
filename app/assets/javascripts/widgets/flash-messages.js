// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
// @license-end
