Diaspora.Pages.GroupsShow = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.aspectNavigation = self.instantiate("AspectNavigation", document.find("ul#aspect_nav"));
    self.stream = self.instantiate("Stream", document.find("#main_stream"));
    self.infiniteScroll = self.instantiate("InfiniteScroll");
    self.instantiate("TimeAgo", document.find("abbr.timeago"));
  });
};
