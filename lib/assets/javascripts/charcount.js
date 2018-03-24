// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*
 * char count plugin
 * options are:
 * - allowed: number of allowed characters
 * - warning: number of left characters when a warning should be displayed
 * - counter: jQuery element to use as the counter
 */
$.fn.charCount = function(opts) {
  this.each(function() {
    var $this = $(this);
    var counter = opts.counter;

    var update = function() {
      var count = $this.val().length;

      if (count > opts.allowed) {
        counter.removeClass("text-warning").addClass("text-danger");
      } else if (count > opts.allowed - opts.warning) {
        counter.removeClass("text-danger").addClass("text-warning");
      } else {
        counter.removeClass("text-danger").removeClass("text-warning");
      }

      counter.text(opts.allowed - count);
    };

    $this.on("textchange", update);
    update();
  });
};
// @license-end
