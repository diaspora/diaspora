(function() {
  app.helpers.truncate = function(passedString, length) {
    if (passedString === null || passedString === undefined || passedString.length < length) {
      return passedString;
    }

    var lastBlank = passedString.lastIndexOf(" ", length);
    var trimstring = passedString.substring(0, Math.min(length, lastBlank));
    return trimstring + " ...";
  };
})();
