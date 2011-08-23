Diaspora.Pages.PeopleFeaturedUsers = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.instantiate("Header", document.find("header"));


    self.hoverCard = self.instantiate("HoverCard", document.find("#hovercard"));
    self.directionDetector = self.instantiate("DirectionDetector");
    self.flashMessages = self.instantiate("FlashMessages");
  });
};
