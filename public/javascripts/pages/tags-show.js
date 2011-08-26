Diaspora.Pages.TagsShow = function() {
  var self = this;

  this.subscribe("page/ready", function() {
    self.infiniteScroll = self.instantiate("InfiniteScroll");
  });
};
