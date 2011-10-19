Diaspora.Pages.UsersGettingStarted = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.peopleSearch = self.instantiate("Search", body.find("form.people.search_form"));
    self.tagSearch = self.instantiate("Search", body.find("form.tag_input.search_form"));
    
    $("#profile_first_name").bind("change", function(){
      $('#edit_profile').bind('ajax:success', function(evt, data, status, xhr){
        $('#form_spinner').addClass("hidden");
        $('.profile .saved').removeClass("hidden");
        $('.profile .saved').fadeOut(2000);
      });
      $('#edit_profile').submit();
      $('#form_spinner').removeClass("hidden");
    });
  });
};
