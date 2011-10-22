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

    $("#profile_first_name").bind("blur", function(){
      $(this).removeClass("active_input");
    });

    $("#profile_first_name").bind("focus", function(){
      $(this).addClass("active_input");
    });

    $("#awesome_button").bind("click", function(evt){
      evt.preventDefault();
      $('#awesome_spinner').removeClass("hidden");
      $('.tag_input').submit();
    });

    /* ------ */
    var autocompleteInput = $("#follow_tags");

    autocompleteInput.autoSuggest("/tags", {
      selectedItemProp: "name",
      searchObjProps: "name",
      asHtmlID: "tags",
      neverSubmit: true,
      retriveLimit: 10,
      selectionLimit: false,
      minChars: 2,
      keyDelay: 200,
      startText: "",
      emptyText: "no_results"
      });

    autocompleteInput.bind('keydown', function(evt){
      if(evt.keyCode == 13 || evt.keyCode == 9 || evt.keyCode == 32){
        evt.preventDefault();
        if( $('li.as-result-item.active').length == 0 ){
          $('li.as-result-item').first().click();
        }
      }
    });
  });
};
