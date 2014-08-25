app.views.Contacts = Backbone.View.extend({

  el: "#contacts_container",

  events: {
    "click #contacts_visibility_toggle" : "toggleContactVisibility",
    "click #change_aspect_name" : "showAspectNameForm",
    "click .contact_remove-from-aspect" : "removeContactFromAspect",
    "click .contact_add-to-aspect" : "addContactToAspect",
    "keyup #contact_list_search" : "searchContactList"
  },

  initialize: function() {
    this.visibility_toggle = $("#contacts_visibility_toggle .entypo");
    $("#people_stream.contacts .header .entypo").tooltip({ 'placement': 'bottom'});
    $(".contact_remove-from-aspect").tooltip();
    $(".contact_add-to-aspect").tooltip();
    $(document).on('ajax:success', 'form.edit_aspect', this.updateAspectName);
  },

  toggleContactVisibility: function() {
    if (this.visibility_toggle.hasClass("lock-open")) {
      this.visibility_toggle.removeClass("lock-open")
                            .addClass("lock")
                            .tooltip("destroy")
                            .removeAttr("data-original-title")
                            .attr("title", Diaspora.I18n.t("contacts.aspect_list_is_not_visible"))
                            .tooltip({'placement': 'bottom'});
    }
    else {
      this.visibility_toggle.removeClass("lock")
                            .addClass("lock-open")
                            .tooltip("destroy")
                            .removeAttr("data-original-title")
                            .attr("title", Diaspora.I18n.t("contacts.aspect_list_is_visible"))
                            .tooltip({'placement': 'bottom'});
    }
  },

  showAspectNameForm: function() {
    $(".header > h3").hide();
    $(".header > #aspect_name_form").show();
  },

  updateAspectName: function(evt,data,status,xhr){
    $(".header #aspect_name").text(data['name']);
    $("#aspect_nav [data-aspect-id='"+data['id']+"'] .name").text(data['name']);
    $(".header > #aspect_name_form").hide();
    $(".header > h3").show();
  },

  addContactToAspect: function(e){
    var contact = $(e.currentTarget);
    var aspect_membership = new app.models.AspectMembership({
      'person_id': contact.data('person_id'),
      'aspect_id': contact.data('aspect_id')
    });

    aspect_membership.save({
      success: function(model,response){
        contact.attr('data-membership_id',model.id)
               .tooltip('destroy')
               .removeAttr('data-original-title')
               .removeClass("contact_add-to_aspect").removeClass("circled-plus")
               .addClass("contact_remove-from_aspect").addClass("circled-cross")
               .attr('title', Diaspora.I18n.t('contacts.add_contact'))
               .tooltip()
               .closest('.stream_element').removeClass('not_in_aspect');
      },
      error: function(model,response){
        alert("SAVE ERROR " + JSON.stringify(model));
      }
    });
  },

  removeContactFromAspect: function(e){
    var contact = $(e.currentTarget);
    var aspect_membership = new app.models.AspectMembership({
      'id': contact.data('membership_id')
    });

    aspect_membership.destroy({
      success: function(model,response){
        contact.removeAttr('data-membership_id')
               .tooltip('destroy')
               .removeAttr('data-original-title')
               .removeClass("contact_remove-from_aspect").removeClass("circled-cross")
               .addClass("contact_add-to_aspect").addClass("circled-plus")
               .attr('title', Diaspora.I18n.t('contacts.add_contact'))
               .tooltip()
               .closest('.stream_element').addClass('not_in_aspect');
      },
      error: function(model,response){
        alert("DESTROY ERROR " + JSON.stringify(model));
      }
    });
  },

  searchContactList: function(e) {
    var query = new RegExp($(e.target).val(),'i');

    $("#people_stream.stream.contacts .stream_element").each(function(){
      if($(this).find(".name").text().match(query)){
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  }
});
