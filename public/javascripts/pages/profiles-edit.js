Diaspora.Pages.ProfilesEdit = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.header = self.instantiate("Header", body.find("header"));

//    self.peopleSearch = self.instantiate("Search", body.find("#update_profile_form"));
  });
};