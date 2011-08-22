Diaspora.Pages.UsersEdit = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.header = self.instantiate("Header", body.find("header"));
  });
};