Diaspora.Pages.TagsShow = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.stream = self.instantiate("Stream", document.find("#main_stream"));
    self.infiniteScroll = self.instantiate("InfiniteScroll");
    self.instantiate("TimeAgo", document.find("abbr.timeago"));
  });
};
