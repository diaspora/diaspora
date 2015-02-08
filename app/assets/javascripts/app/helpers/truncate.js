(function() {
  app.helpers.truncate = function(passedString, length) {
    if (passedString === null || passedString === undefined) {
      return passedString;
    }

    if (passedString.length > length) {
      var lastBlank = passedString.lastIndexOf(' ', length);
      var trimstring = passedString.substring(0, Math.min(length, lastBlank));
      return new Handlebars.SafeString(trimstring + " ...");
    }
    return new Handlebars.SafeString(passedString);
  };
})();
