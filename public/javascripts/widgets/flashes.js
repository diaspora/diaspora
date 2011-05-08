(function() {
  var Flashes = function() {
    this.start = function() {
      this.animateMessages();
    };

    this.animateMessages = function() {
      var $this = $("#flash_notice, #flash_error, #flash_alert");
      $this.animate({
        top: 0
      }).delay(2000).animate({
        top: -100
      }, $this.remove);
    };

    this.render = function(result) {
      $("<div/>")
        .attr("id", (result.success) ? "flash_notice" : "flash_error")
        .prependTo(document.body)
        .html(result.notice);

      this.animateMessages();
    };
  };

  Diaspora.widgets.add("flashes", Flashes);
})();