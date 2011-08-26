 (function($) {
  function debounce(callback, delay) {
    var self = this, timeout, _arguments;
    return function() {
      _arguments = Array.prototype.slice.call(arguments, 0),
      timeout = clearTimeout(timeout, _arguments),
      timeout = setTimeout(function() {
        callback.apply(self, _arguments);
        timeout = 0;
      }, delay);

      return this;
    };
  }

  $.extend($.fn, {
    debounce: function(event, callback, delay) {
      this.bind(event, debounce.apply(this, [callback, delay]));
    }
  });
})(jQuery);