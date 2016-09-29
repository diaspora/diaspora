// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ConversationsForm = Backbone.View.extend({
  el: ".conversations-form-container",

  events: {
    "keydown .conversation-message-text": "keyDown",
    "submit #conversation-new": "onSubmitNewConversation"
  },

  initialize: function(opts) {
    this.contacts = _.has(opts, "contacts") ? opts.contacts : null;
    this.prefill = [];
    if (_.has(opts, "prefillName") && _.has(opts, "prefillValue")) {
      this.prefill = [{name: opts.prefillName, value: opts.prefillValue}];
    }
    this.prepareAutocomplete(this.contacts);
  },

  prepareAutocomplete: function(data){
    this.$("#contact-autocomplete").autoSuggest(data, {
      selectedItemProp: "name",
      searchObjProps: "name",
      asHtmlID: "contact_ids",
      retrieveLimit: 10,
      minChars: 1,
      keyDelay: 0,
      startText: '',
      emptyText: Diaspora.I18n.t("no_results"),
      preFill: this.prefill
    });
    $("#contact_ids").attr("aria-labelledby", "toLabel").focus();
  },

  keyDown : function(evt) {
    if(evt.which === Keycodes.ENTER && evt.ctrlKey) {
      $(evt.target).parents("form").submit();
    }
  },

  getConversationParticipants: function() {
    return this.$("#as-values-contact_ids").val().split(",");
  },

  onSubmitNewConversation: function(evt) {
    evt.preventDefault();
    if (this.getConversationParticipants().length === 0) {
      evt.stopPropagation();
      app.flashMessages.error(Diaspora.I18n.t("conversation.create.no_recipient"));
    }
  }
});
// @license-end

