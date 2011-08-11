Diaspora.Pages.ContactsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.instantiate("Header", document.find("header"));

    self.hoverCard = self.instantiate("HoverCard", document.find("#hovercard"));
    self.infiniteScroll = self.instantiate("InfiniteScroll");
    self.timeAgo = self.instantiate("TimeAgo", "abbr.timeago");
    self.directionDetector = self.instantiate("DirectionDetector");
    self.flashMessages = self.instantiate("FlashMessages");
  });
};
