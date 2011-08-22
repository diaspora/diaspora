Diaspora.Pages.PeopleIndex = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.header = self.instantiate("Header", body.find("header"));
  });
};