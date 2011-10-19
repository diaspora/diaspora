Diaspora.Pages.UsersGettingStarted = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.peopleSearch = self.instantiate("Search", body.find("form.people.search_form"));
    self.tagSearch = self.instantiate("Search", body.find("form.tag_input.search_form"));
    
    $('#edit_profile').bind('ajax:success', function(evt, data, status, xhr){
      $('#form_spinner').addClass("hidden");
      $('.profile .saved').show();
      $('.profile .saved').fadeOut(2000);
    });

    // It seems that the default behavior of rails ujs is to clear the remote form
    $('#edit_profile').bind('ajax:complete', function(evt, xhr, status){
      var firstNameField = $("#profile_first_name");
      firstNameField.val(firstNameField.data("cachedValue"));
    });



    $("#profile_first_name").bind("change", function(){
      $(this).data("cachedValue", $(this).val());
      $('#edit_profile').submit();
      $('#form_spinner').removeClass("hidden");

    });
  });
};
