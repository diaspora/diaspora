//= require ../search_base_view

app.views.PublisherMention = app.views.SearchBase.extend({
  triggerChar: "@",
  invisibleChar: "\u200B", // zero width space
  mentionRegex: /@([^@\s]+)$/,

  templates: {
    mentionItemSyntax: _.template("@{<%= name %> ; <%= handle %>}"),
    mentionItemHighlight: _.template("<strong><span><%= name %></span></strong>")
  },

  events: {
    "keydown #status_message_fake_text": "onInputBoxKeyDown",
    "input #status_message_fake_text": "onInputBoxInput",
    "click #status_message_fake_text": "onInputBoxClick",
    "blur #status_message_fake_text": "onInputBoxBlur"
  },

  initialize: function() {
    this.mentionedPeople = [];

    // contains the 'fake text' displayed to the user
    // also has a data-messageText attribute with the original text
    this.inputBox = this.$("#status_message_fake_text");
    // contains the mentions displayed to the user
    this.mentionsBox = this.$(".mentions-box");
    this.typeaheadInput = this.$(".typeahead-mention-box");
    this.bindTypeaheadEvents();

    app.views.SearchBase.prototype.initialize.call(this, {
      typeaheadInput: this.typeaheadInput,
      customSearch: true,
      autoselect: true,
      remoteRoute: {url: "/contacts"}
    });
  },

  bindTypeaheadEvents: function() {
    var self = this;
    // Process mention when the user selects a result.
    this.typeaheadInput.on("typeahead:select", function(evt, person) { self.onSuggestionSelection(person); });
  },

  addPersonToMentions: function(person) {
    if(!(person && person.name && person.handle)) { return; }
    // This is needed for processing preview
    /* jshint camelcase: false */
    person.diaspora_id = person.handle;
    /* jshint camelcase: true */
    this.mentionedPeople.push(person);
    this.ignorePersonForSuggestions(person);
  },

  cleanMentionedPeople: function() {
    var inputText = this.inputBox.val();
    this.mentionedPeople = this.mentionedPeople.filter(function(person) {
      return person.name && inputText.indexOf(person.name) > -1;
    });
    this.ignoreDiasporaIds = this.mentionedPeople.map(function(person) { return person.handle; });
  },

  onSuggestionSelection: function(person) {
    var messageText = this.inputBox.val();
    var caretPosition = this.inputBox[0].selectionStart;
    var triggerCharPosition = messageText.lastIndexOf(this.triggerChar, caretPosition);

    if(triggerCharPosition === -1) { return; }

    this.addPersonToMentions(person);
    this.closeSuggestions();

    messageText = messageText.substring(0, triggerCharPosition) +
      this.invisibleChar + person.name + messageText.substring(caretPosition);

    this.inputBox.val(messageText);
    this.updateMessageTexts();

    this.inputBox.focus();
    var newCaretPosition = triggerCharPosition + person.name.length + 1;
    this.inputBox[0].setSelectionRange(newCaretPosition, newCaretPosition);
  },

  /**
   * Replaces every combination of this.invisibleChar + mention.name by the
   * correct syntax for both hidden text and visible one.
   *
   * For instance, the text "Hello \u200Buser1" will be tranformed to
   * "Hello @{user1 ; user1@pod.tld}" in the hidden element and
   * "Hello <strong><span>user1</span></strong>" in the element visible to the user.
   */
  updateMessageTexts: function() {
    var fakeMessageText = this.inputBox.val(),
        mentionBoxText = _.escape(fakeMessageText),
        messageText = fakeMessageText;

    this.mentionedPeople.forEach(function(person) {
      var mentionName = this.invisibleChar + person.name;
      messageText = messageText.replace(mentionName, this.templates.mentionItemSyntax(person));
      var textHighlight = this.templates.mentionItemHighlight({name: _.escape(person.name)});
      mentionBoxText = mentionBoxText.replace(mentionName, textHighlight);
    }, this);

    this.inputBox.data("messageText", messageText);
    this.mentionsBox.find(".mentions").html(mentionBoxText);
  },

  updateTypeaheadInput: function() {
    var messageText = this.inputBox.val();
    var caretPosition = this.inputBox[0].selectionStart;
    var result = this.mentionRegex.exec(messageText.substring(0,caretPosition));

    if(result === null) {
      this.closeSuggestions();
      return;
    }

    // result[1] is the string between the last '@' and the current caret position
    this.typeaheadInput.typeahead("val", result[1]);
    this.typeaheadInput.typeahead("open");
  },

  /**
   * Let us prefill the publisher with a mention list
   * @param persons List of people to mention in a post;
   * JSON object of form { handle: <diaspora handle>, name: <name>, ... }
   */
  prefillMention: function(persons) {
    persons.forEach(function(person) {
      this.addPersonToMentions(person);
      var text = this.invisibleChar + person.name;
      if(this.inputBox.val().length !== 0) {
        text = this.inputBox.val() + " " + text;
      }
      this.inputBox.val(text);
      this.updateMessageTexts();
    }, this);
  },

  /**
   * Selects next or previous result when result dropdown is open and
   * user press up and down arrows.
   */
  onArrowKeyDown: function(e) {
    if(!this.isVisible() || (e.which !== Keycodes.UP && e.which !== Keycodes.DOWN)) {
      return;
    }

    e.preventDefault();
    e.stopPropagation();

    this.typeaheadInput.typeahead("activate");
    this.typeaheadInput.typeahead("open");
    this.typeaheadInput.trigger($.Event("keydown", {keyCode: e.keyCode, which: e.which}));
  },

  /**
   * Listens for user input and opens results dropdown when input contains the trigger char
   */
  onInputBoxInput: function() {
    this.cleanMentionedPeople();
    this.updateMessageTexts();
    this.updateTypeaheadInput();
  },

  onInputBoxKeyDown: function(e) {
    // This also matches HOME/END on OSX which is CMD+LEFT, CMD+RIGHT
    if(e.which === Keycodes.LEFT || e.which === Keycodes.RIGHT ||
       e.which === Keycodes.HOME || e.which === Keycodes.END) {
      _.defer(_.bind(this.updateTypeaheadInput, this));
      return;
    }

    if(!this.isVisible) {
      return true;
    }

    switch(e.which) {
      case Keycodes.ESC:
      case Keycodes.SPACE:
        this.closeSuggestions();
        break;
      case Keycodes.UP:
      case Keycodes.DOWN:
        this.onArrowKeyDown(e);
        break;
      case Keycodes.RETURN:
      case Keycodes.TAB:
        if(this.$(".tt-cursor").length === 1) {
           this.$(".tt-cursor").click();
          return false;
        }
        break;
    }
    return true;
  },

  onInputBoxClick: function() {
    this.updateTypeaheadInput();
  },

  onInputBoxBlur: function() {
    this.closeSuggestions();
  },

  reset: function() {
    this.inputBox.val("");
    this.onInputBoxInput();
  },

  closeSuggestions: function() {
    this.typeaheadInput.typeahead("val", "");
    this.typeaheadInput.typeahead("close");
  },

  isVisible: function() {
    return this.$(".tt-menu").is(":visible");
  },

  getTextForSubmit: function() {
    return this.mentionedPeople.length ? this.inputBox.data("messageText") : this.inputBox.val();
  }
});
