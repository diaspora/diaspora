Diaspora.Pages.UsersGettingStarted = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.peopleSearch = self.instantiate("Search", body.find("form.people.search_form"));
    self.tagSearch = self.instantiate("Search", body.find("form.tag_input.search_form"));

    $('#edit_profile').bind('ajax:success', function(evt, data, status, xhr){
      $('#gs-name-form-spinner').addClass("hidden");
    });

    // It seems that the default behavior of rails ujs is to clear the remote form
    $('#edit_profile').bind('ajax:complete', function(evt, xhr, status){
      var firstNameField = $("#profile_first_name");
      firstNameField.val(firstNameField.data("cachedValue"));

      /* flash message prompt */
      var message = Diaspora.I18n.t("getting_started.hey", {'name': $("#profile_first_name").val()});
      Diaspora.page.flashMessages.render({success: true, notice: message});
    });

    $("#profile_first_name").bind("change", function(){
      $(this).data("cachedValue", $(this).val());
      $('#edit_profile').submit();
      $('#gs-name-form-spinner').removeClass("hidden");
    });

    $("#profile_first_name").bind("blur", function(){
      $(this).removeClass("active_input");
    });

    $("#profile_first_name").bind("focus", function(){
      $(this).addClass("active_input");
    });

    $("#awesome_button").bind("click", function(evt){
      var confirmMessage = Diaspora.I18n.t("getting_started.no_tags");
      var message = Diaspora.I18n.t("getting_started.preparing_your_stream");
      var confirmation = true;

      if ($("#as-selections-tags").find(".as-selection-item").length <= 0) {
        message = Diaspora.I18n.t("getting_started.alright_ill_wait");
        confirmation = confirm(confirmMessage);
      }

      Diaspora.page.flashMessages.render({success: true, notice: message});
      return confirmation;
    });

    /* ------ */
    var autocompleteInput = $("#follow_tags");
    var tagFollowings = new app.collections.TagFollowings();

    autocompleteInput.autoSuggest("/tags", {
      selectedItemProp: "name",
      selectedValuesProp: "name",
      searchObjProps: "name",
      asHtmlID: "tags",
      neverSubmit: true,
      retrieveLimit: 10,
      selectionLimit: false,
      minChars: 2,
      keyDelay: 200,
      startText: "",
      emptyText: "no_results",
      selectionAdded: function(elem){tagFollowings.create({"name":$(elem[0]).text().substring(2)})},
      selectionRemoved: function(elem){ 
        tagFollowings.where({"name":$(elem[0]).text().substring(2)})[0].destroy();
        elem.remove();
      }
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
