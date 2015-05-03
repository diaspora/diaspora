// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.pages.Contacts = Backbone.View.extend({

  el: "#contacts_container",

  events: {
    "click #contacts_visibility_toggle" : "toggleContactVisibility",
    "click #chat_privilege_toggle" : "toggleChatPrivilege",
    "click #change_aspect_name" : "showAspectNameForm",
    "keyup #contact_list_search" : "searchContactList"
  },

  initialize: function(opts) {
    this.visibility_toggle = $("#contacts_visibility_toggle .entypo");
    this.chat_toggle = $("#chat_privilege_toggle .entypo");
    this.stream = opts.stream;
    this.stream.render();
    $("#people_stream.contacts .header .entypo").tooltip({ 'placement': 'bottom'});
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

  updateAspectName: function(evt,data){
    $(".header #aspect_name").text(data['name']);
    $("#aspect_nav [data-aspect-id='"+data['id']+"'] .name").text(data['name']);
    $(".header > #aspect_name_form").hide();
    $(".header > h3").show();
  },

  searchContactList: function(e) {
    this.stream.search($(e.target).val());
  }
});
// @license-end

