Diaspora.Pages.AuthorizationsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.instantiate("Header", document.find("header"));
    self.directionDetector = self.instantiate("DirectionDetector");
    self.flashMessages = self.instantiate("FlashMessages");
  });
};
