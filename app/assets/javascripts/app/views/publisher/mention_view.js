//= require ../search_base_view

app.views.PublisherMention = app.views.SearchBase.extend({
  triggerChar: "@",
  mentionRegex: /@([^@\s]+)$/,
  mentionSyntaxTemplate: function(person) { return "@{" + person.handle + "}"; },

  events: {
    "keydown .mention-textarea": "onInputBoxKeyDown",
    "input .mention-textarea": "updateTypeaheadInput",
    "click .mention-textarea": "onInputBoxClick",
    "blur .mention-textarea": "onInputBoxBlur"
  },

  initialize: function(opts) {
    this.mentionedPeople = [];
    var url = (opts && opts.url) || "/contacts";
    this.inputBox = this.$(".mention-textarea");
    this.typeaheadInput = this.$(".typeahead-mention-box");
    this.bindTypeaheadEvents();

    app.views.SearchBase.prototype.initialize.call(this, {
      typeaheadInput: this.typeaheadInput,
      customSearch: true,
      autoselect: true,
      remoteRoute: {url: url}
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
      return person.handle && inputText.indexOf(this.mentionSyntaxTemplate(person)) > -1;
    }.bind(this));
    this.ignoreDiasporaIds = this.mentionedPeople.map(function(person) { return person.handle; });
  },

  onSuggestionSelection: function(person) {
    var messageText = this.inputBox.val();
    var caretPosition = this.inputBox[0].selectionStart;
    var triggerCharPosition = messageText.lastIndexOf(this.triggerChar, caretPosition);

    if(triggerCharPosition === -1) { return; }

    this.addPersonToMentions(person);
    this.closeSuggestions();

    var mentionText = this.mentionSyntaxTemplate(person);

    messageText = messageText.substring(0, triggerCharPosition) + mentionText + messageText.substring(caretPosition);

    this.inputBox.val(messageText);
    this.inputBox.focus();
    var newCaretPosition = triggerCharPosition + mentionText.length;
    this.inputBox[0].setSelectionRange(newCaretPosition, newCaretPosition);
  },

  updateTypeaheadInput: function() {
    var messageText = this.inputBox.val();
    var caretPosition = this.inputBox[0].selectionStart;
    var result = this.mentionRegex.exec(messageText.substring(0,caretPosition));

    if(result === null) {
      this.closeSuggestions();
      return;
    }

    this.cleanMentionedPeople();

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
      var text = this.mentionSyntaxTemplate(person);
      if(this.inputBox.val().length !== 0) {
        text = this.inputBox.val() + " " + text;
      }
      this.inputBox.val(text);
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
    this.updateTypeaheadInput();
  },

  closeSuggestions: function() {
    this.typeaheadInput.typeahead("val", "");
    this.typeaheadInput.typeahead("close");
  },

  isVisible: function() {
    return this.$(".tt-menu").is(":visible");
  },

  getMentionedPeople: function() {
    this.cleanMentionedPeople();
    return this.mentionedPeople;
  }
});
