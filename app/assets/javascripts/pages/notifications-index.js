Diaspora.Pages.NotificationsIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, document) {
    self.infiniteScroll = self.instantiate("InfiniteScroll");
    self.instantiate("TimeAgo", document.find("time.timeago"));
  });
};
