Diaspora.Pages.PostsShow = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.header = self.instantiate("Header", body.find("header"));
    self.stream = self.instantiate("Stream", body.find("#main_stream"));
  });
};