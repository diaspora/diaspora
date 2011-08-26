Diaspora.Pages.AspectsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.stream = self.instantiate("Stream", document.find("#aspect_stream_container"));
    self.header = self.instantiate("Header", document.find("header"));

    self.backToTop = self.instantiate("BackToTop", document.find("#back-to-top"));
    self.hoverCard = self.instantiate("HoverCard", document.find("#hovercard"));
    self.infiniteScroll = self.instantiate("InfiniteScroll");
    self.timeAgo = self.instantiate("TimeAgo", "abbr.timeago");
    self.directionDetector = self.instantiate("DirectionDetector");
    self.flashMessages = self.instantiate("FlashMessages");
  });
};