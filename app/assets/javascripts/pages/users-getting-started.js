// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Diaspora.Pages.UsersGettingStarted = function() {
  var self = this;

  this.subscribe("page/ready", function(evt, body) {
    self.peopleSearch = self.instantiate("Search", body.find("form.people.search_form"));
    self.tagSearch = self.instantiate("Search", body.find("form.tag_input.search_form"));

    $('#edit_profile').bind('ajax:success', function(){
      $('#gs-name-form-spinner').addClass("hidden");
    });

    // It seems that the default behavior of rails ujs is to clear the remote form
    $('#edit_profile').bind('ajax:complete', function(){
      var firstNameField = $("#profile_first_name");
      firstNameField.val(firstNameField.data("cachedValue"));

      /* flash message prompt */
      var message = Diaspora.I18n.t("getting_started.hey", {'name': $("#profile_first_name").val()});
      app.flashMessages.success(message);
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

    $("#awesome_button").bind("click", function(){
      var confirmMessage = Diaspora.I18n.t("getting_started.no_tags");
      var message = Diaspora.I18n.t("getting_started.preparing_your_stream");
      var confirmation = true;

      if ($("#as-selections-tags").find(".as-selection-item").length <= 0) {
        message = Diaspora.I18n.t("getting_started.alright_ill_wait");
        confirmation = confirm(confirmMessage);
      }

      app.flashMessages.success(message);
      return confirmation;
    });

    var tagFollowings = new app.collections.TagFollowings();
    new Diaspora.TagsAutocomplete("#follow_tags", {
      preFill: gon.preloads.tagsArray,
      selectionAdded: function(elem){tagFollowings.create({"name":$(elem[0]).text().substring(2)})},
      selectionRemoved: function(elem){
        tagFollowings.where({"name":$(elem[0]).text().substring(2)})[0].destroy();
        elem.remove();
      }
    });
    new Diaspora.ProfilePhotoUploader();
  });
};
// @license-end

