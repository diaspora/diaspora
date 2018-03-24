// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ConversationsForm = app.views.Base.extend({
  el: ".conversations-form-container",

  events: {
    "keydown .conversation-message-text": "keyDown",
    "click .conversation-recipient-tag .remove": "removeRecipient"
  },

  initialize: function(opts) {
    opts = opts || {};
    this.conversationRecipients = [];

    this.typeaheadElement = this.$el.find("#contacts-search-input");
    this.contactsIdsListInput = this.$el.find("#contact-ids");
    this.tagListElement = this.$("#recipients-tag-list");

    this.search = new app.views.SearchBase({
      el: this.$el.find("#new-conversation"),
      typeaheadInput: this.typeaheadElement,
      customSearch: true,
      autoselect: true,
      remoteRoute: {url: "/contacts", extraParameters: "mutual=true"}
    });

    this.newConversationMdEditor = this.renderMarkdownEditor("#new-message-text");

    this.bindTypeaheadEvents();

    this.tagListElement.empty();
    if (opts.prefill) {
      this.prefill(opts.prefill);
    }

    this.$("form#new-conversation").on("ajax:success", this.conversationCreateSuccess.bind(this));
    this.$("form#new-conversation").on("ajax:error", this.conversationCreateError);
  },

  renderMarkdownEditor: function(element) {
    return new Diaspora.MarkdownEditor($(element), {
      onPreview: Diaspora.MarkdownEditor.simplePreview
    });
  },

  addRecipient: function(person) {
    this.conversationRecipients.push(person);
    this.updateContactIdsListInput();
    /* eslint-disable camelcase */
    var personEl = $(HandlebarsTemplates.conversation_recipient_tag_tpl(person)).appendTo(this.tagListElement);
    /* eslint-enable camelcase */
    this.setupAvatarFallback(personEl);
  },

  prefill: function(people) {
    people.forEach(function(person) {
      this.addRecipient(_.extend({
        avatar: person.get("profile").avatar.small,
        handle: person.get("diaspora_id")
      }, person.attributes));
    }, this);
  },

  updateContactIdsListInput: function() {
    this.contactsIdsListInput.val(_(this.conversationRecipients).pluck("id").join(","));
    this.search.ignoreDiasporaIds.length = 0;
    this.conversationRecipients.forEach(this.search.ignorePersonForSuggestions.bind(this.search));
  },

  bindTypeaheadEvents: function() {
    this.typeaheadElement.on("typeahead:select", function(evt, person) {
      this.onSuggestionSelection(person);
    }.bind(this));
  },

  onSuggestionSelection: function(person) {
    this.addRecipient(person);
    this.typeaheadElement.typeahead("val", "");
  },

  keyDown: function(evt) {
    if (evt.which === Keycodes.ENTER && (evt.metaKey || evt.ctrlKey)) {
      $(evt.target).parents("form").submit();
    }
  },

  removeRecipient: function(evt) {
    var $recipientTagEl = $(evt.target).parents(".conversation-recipient-tag");
    var diasporaHandle = $recipientTagEl.data("diaspora-handle");

    this.conversationRecipients = this.conversationRecipients.filter(function(person) {
      return diasporaHandle !== person.handle;
    });

    this.updateContactIdsListInput();
    $recipientTagEl.remove();
  },

  conversationCreateSuccess: function(evt, data) {
    this.newConversationMdEditor.hidePreview();
    app._changeLocation(Routes.conversation(data.id));
  },

  conversationCreateError: function(evt, resp) {
    app.flashMessages.error(resp.responseText);
  }
});
// @license-end
