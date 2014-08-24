app.views.Contacts = Backbone.View.extend({

  el: "#contacts_container",

  events: {
    "click #contacts_visibility_toggle" : "toggleContactVisibility",
    "click #change_aspect_name" : "showNameChangeForm"
  },

  initialize: function() {
    this.visibility_toggle = $("#contacts_visibility_toggle .entypo");
    $("#people_stream.contacts .header .entypo").tooltip({ 'placement': 'bottom'});
    $(".contact_remove-from-aspect").tooltip();
    $(document).on('ajax:success', 'form.edit_aspect', this.updateAspectName);
  },

  toggleContactVisibility: function() {
    if (this.visibility_toggle.hasClass("lock-open")) {
      this.visibility_toggle.removeClass("lock-open")
                            .addClass("lock")
                            .tooltip("destroy")
                            .removeAttr("data-original-title")
                            .attr("title", Diaspora.I18n.t("aspects.edit.aspect_list_is_not_visible"))
                            .tooltip();
    }
    else {
      this.visibility_toggle.removeClass("lock")
                            .addClass("lock-open")
                            .tooltip("destroy")
                            .removeAttr("data-original-title")
                            .attr("title", Diaspora.I18n.t("aspects.edit.aspect_list_is_visible"))
                            .tooltip();
    }
  },

  showNameChangeForm: function() {
    $(".header > h3").hide();
    $(".header > #aspect_name_form").show();
  },

  updateAspectName: function(evt,data,status,xhr){
    $(".header #aspect_name").text(data['name']);
    $("#aspect_nav [data-aspect-id='"+data['id']+"'] .name").text(data['name']);
    $(".header > #aspect_name_form").hide();
    $(".header > h3").show();
  }
});
