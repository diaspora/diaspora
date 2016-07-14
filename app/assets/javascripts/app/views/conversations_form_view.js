// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ConversationsForm = Backbone.View.extend({
  el: ".conversations-form-container",

  events: {
    "keydown textarea.conversation-message-text": "keyDown",
    "submit #conversation-new": "onSubmitForm"
  },

  initialize: function(opts) {
    this.conversationParticipants = [];

    this.search = new app.views.SearchBase({
      el: this.$el.find("#new-conversation"),
      typeaheadInput: this.getTypeaheadElement(),
      customSearch: true,
      autoselect: true,
      remoteRoute: "/contacts"
    });

    this.contactsTags = this.getContactsTagsElement().tags({
      tagData: [],
      tagClass: "btn-primary conversation-contact-tag",
      afterDeletingTag: this.onDeleteTag.bind(this)
    });

    this.bindTypeaheadEvents();

    if (opts && opts.prefills) {
      this.prefill(opts.prefills);
    }
  },

  /**
   * Constructs the tag text from the person.
   *
   * If the person has no nickname (i.e.: if its handle is its nickname), then it just returns
   * the handle. Otherise, it will construct the tag text from the nickname and the handle.
   * For instance, given the person {name: "diaspora user", handle: "diaspora-user@pod.tld"},
   * this will construct the following tag text: "diaspora user \u200B(diaspora-user@pod.tld)"
   * The unicode litteral \u200B is an invisible character used to mark the starting of the user's
   * handle. It will be used when the tag is removed (see #extractHandleFromTag). As this invisible
   * caracter is used as a marker, it is preventively stripped from the person's handle and name
   * when the text is built.
   *
   * Note: Prior ES6, you can't construct a regexp object from a string containing unicode literals
   * which forces us to use inline regexp notation using the unicode litteral \u200B.
   *
   * @param person
   * @returns {String}
   */
  getTagFromPerson: function(person) {
    if (person.handle.localeCompare(person.name) === 0) {
      return person.handle;
    }
    return person.name.replace(/\u200B/g, "").trim() + " \u200B(" + person.handle.replace(/\u200B/g, "").trim() + ")";
  },

  /**
   * Extracts the handle of the user from a tag text.
   *
   * If the person has no nickname, the tag text is considered to be composed from the user's
   * handle only. Hence, if the text \u200B(person.handle) is not found in the tag text,
   * it is returned as is. Otherwise, it extracts the user handle from the tag text. For instance,
   * given the tag text "diaspora user \u200B(diaspora-user@pod.tld), this function will return
   * "diaspora-user@pod.tld". This function is used in #onDeleteTag callback that is invoked
   * each time the user remove a recipiant from the conversation. It is used so that
   * the callback does not suppress multiple user that have the same nickname.
   *
   * Note: Prior ES6, you can't construct a regexp object from a string containing unicode literals
   * which forces us to use inline regexp notation using the unicode litteral \u200B.
   *
   * @param tag The tag text (String)
   * @returns {String} The extracted handle
   */
  extractHandleFromTag: function(tag) {
    if (tag.search(/\u200B\((.*)\)/) === -1) {
      return tag;
    }
    return /^.* \u200B\((.*)\)$/g.exec(tag)[1];
  },

  onDeleteTag: function(tag) {
    this.conversationParticipants = this.conversationParticipants.filter(function(person) {
      var handle = this.extractHandleFromTag(tag);
      return handle.localeCompare(person.handle) !== 0;
    }.bind(this));
    this.updateContactIdsListInput();
  },

  prefill: function(handles) {
    handles.forEach(function(handle) { this.addParticipant(handle); }.bind(this));
    this.updateContactIdsListInput();
  },

  addParticipant: function(person) {
    this.conversationParticipants.push(person);
    this.conversationParticipants = _.uniq(this.conversationParticipants, false, _.iteratee("handle"));
  },

  updateContactIdsListInput: function() {
    this.getContactsIdsListInput().val(this.conversationParticipants.map(function(person) {
      return person.id;
    }).join(","));

    this.search.ignoreDiasporaIds.length = 0;
    this.conversationParticipants.forEach(function(person) {
      this.search.ignorePersonForSuggestions(person);
    }.bind(this));

    // Resetting and rendering tags
    this.contactsTags.getTags().length = 0;
    this.contactsTags.renderTags();
    this.conversationParticipants.forEach(function(person) {
      this.contactsTags.addTag(this.getTagFromPerson(person));
    }.bind(this));

    if (this.conversationParticipants.length === 0) {
      this.getContactsTagsElement().addClass("empty-contacts-tags-list");
    } else {
      this.getContactsTagsElement().removeClass("empty-contacts-tags-list");
    }
  },

  bindTypeaheadEvents: function() {
    this.getTypeaheadElement().on("typeahead:select", function(evt, person) {
      this.onSuggestionSelection(person);
    }.bind(this));
  },

  onSuggestionSelection: function(person) {
    this.addParticipant(person);
    this.updateContactIdsListInput();
    this.getTypeaheadElement().typeahead("val", "");
  },

  getTypeaheadElement: function() {
    return this.$el.find("#contacts-search-input");
  },

  getContactsIdsListInput: function() {
    return this.$el.find("#as-values-contact-ids");
  },

  getContactsTagsElement: function() {
    return this.$el.find("#contacts-tags-list");
  },

  keyDown: function(evt) {
    if (evt.which === Keycodes.ENTER && evt.ctrlKey) {
      $(evt.target).parents("form").submit();
    }
  },

  onSubmitForm: function(evt) {
    evt.preventDefault();
    if (this.conversationParticipants.length === 0) {
      evt.stopPropagation();
      app.flashMessages.error(Diaspora.I18n.t("conversation.create.no_contacts"));
    }
  }
});
// @license-end
