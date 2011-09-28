Diaspora.Pages.TagFollowingsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.stream = self.instantiate("Stream", document.find("#aspect_stream_container"));
    self.infiniteScroll = self.instantiate("InfiniteScroll");
  });
};
