Diaspora.Pages.UsersGettingStarted = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.header = self.instantiate("Header", body.find("header"));

    self.peopleSearch = self.instantiate("Search", body.find("form.people.search_form"));
    self.tagSearch = self.instantiate("Search", body.find("form.tag.search_form"));
  });
};