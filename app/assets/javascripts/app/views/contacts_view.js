// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Contacts = Backbone.View.extend({

  el: "#contacts_container",

  events: {
    "click #contacts_visibility_toggle" : "toggleContactVisibility",
    "click #chat_privilege_toggle" : "toggleChatPrivilege",
    "click #change_aspect_name" : "showAspectNameForm",
    "click .contact_remove-from-aspect" : "removeContactFromAspect",
    "click .contact_add-to-aspect" : "addContactToAspect",
    "keyup #contact_list_search" : "searchContactList"
  },

  initialize: function() {
    this.visibility_toggle = $("#contacts_visibility_toggle .entypo");
    this.chat_toggle = $("#chat_privilege_toggle .entypo");
    $("#people_stream.contacts .header .entypo").tooltip({ 'placement': 'bottom'});
    $(".contact_remove-from-aspect").tooltip();
    $(".contact_add-to-aspect").tooltip();
    $(document).on('ajax:success', 'form.edit_aspect', this.updateAspectName);
  },

  toggleChatPrivilege: function() {
    if (this.chat_toggle.hasClass("enabled")) {
      this.chat_toggle.tooltip("destroy")
                      .removeClass("enabled")
                      .removeAttr("data-original-title")
                      .attr("title", Diaspora.I18n.t("contacts.aspect_chat_is_not_enabled"))
                      .tooltip({'placement': 'bottom'});
    } else {
      this.chat_toggle.tooltip("destroy")
                      .addClass("enabled")
                      .removeAttr("data-original-title")
                      .attr("title", Diaspora.I18n.t("contacts.aspect_chat_is_enabled"))
                      .tooltip({'placement': 'bottom'});
    }
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
      'person_id': contact.attr('data-person_id'),
      'aspect_id': contact.attr('data-aspect_id')
    });

    aspect_membership.save({},{
      success: function(model,response){
        contact.attr('data-membership_id',model.id)
               .tooltip('destroy')
               .removeAttr('data-original-title')
               .removeClass("contact_add-to-aspect").removeClass("circled-plus")
               .addClass("contact_remove-from-aspect").addClass("circled-cross")
               .attr('title', Diaspora.I18n.t('contacts.remove_contact'))
               .tooltip()
               .closest('.stream_element').addClass('in_aspect');
      },
      error: function(model,response){
        var msg = Diaspora.I18n.t('contacts.error_add', { 'name':contact.closest('.stream_element').find('.name').text() });
        Diaspora.page.flashMessages.render({ 'success':false, 'notice':msg });
      }
    });
  },

  removeContactFromAspect: function(e){
    var contact = $(e.currentTarget);
    var aspect_membership = new app.models.AspectMembership({
      'id': contact.attr('data-membership_id')
    });

    aspect_membership.destroy({
      success: function(model,response){
        contact.removeAttr('data-membership_id')
               .tooltip('destroy')
               .removeAttr('data-original-title')
               .removeClass("contact_remove-from-aspect").removeClass("circled-cross")
               .addClass("contact_add-to-aspect").addClass("circled-plus")
               .attr('title', Diaspora.I18n.t('contacts.add_contact'))
               .tooltip()
               .closest('.stream_element').removeClass('in_aspect');
      },
      error: function(model,response){
        var msg = Diaspora.I18n.t('contacts.error_remove', { 'name':contact.closest('.stream_element').find('.name').text() });
        Diaspora.page.flashMessages.render({ 'success':false, 'notice':msg });
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
// @license-end

