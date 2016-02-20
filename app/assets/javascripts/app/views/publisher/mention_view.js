//= require ../search_base_view

/*
 * This file is based on jQuery.mentionsInput by Kenneth Auchenberg
 * licensed under MIT License - http://www.opensource.org/licenses/mit-license.php
 * Website: https://podio.github.io/jquery-mentions-input/
 */

app.views.PublisherMention = app.views.SearchBase.extend({
  KEYS: {
    PASTE: 118, BACKSPACE: 8, TAB: 9, RETURN: 13, ESC: 27, LEFT: 37,
    UP: 38, RIGHT: 39, DOWN: 40, COMMA: 188, SPACE: 32, HOME: 36, END: 35
  },

  settings: {
    triggerChar: "@",
    minChars: 2,
    templates: {
      wrapper: _.template("<div class='mentions-input-box'></div>"),
      mentionsOverlay: _.template("<div class='mentions-box'><div class='mentions'><div></div></div></div>"),
      mentionItemSyntax: _.template("@{<%= name %> ; <%= handle %>}"),
      mentionItemHighlight: _.template("<strong><span><%= name %></span></strong>")
    }
  },

  events: {
    "keydown #status_message_fake_text": "onInputBoxKeyDown",
    "keypress #status_message_fake_text": "onInputBoxKeyPress",
    "input #status_message_fake_text": "onInputBoxInput",
    "click #status_message_fake_text": "onInputBoxClick",
    "blur #status_message_fake_text": "onInputBoxBlur",
    "paste #status_message_fake_text": "onInputBoxPaste"
  },

  /**
   * Performs setup of the setup of the plugin.
   *
   * this.mentionsCollection: used to keep track of the people mentionned in the post
   * this.inputBuffer: buffer to keep track of the text currently being typed. It is cleared
   *                   each time a mention has been processed.
   *                   See this#onInputBoxKeyPress
   * this.currentDataQuery: contains the query for the search engine
   *
   * The plugin initilizes two different elements that will contain the text of the post:
   *
   * this.elmInputBox: hidden element which keeps track of typed text formatted following
   *                   the mentioning syntax given by this.settings.templates#mentionItemSyntax
   *                   For instance, if the user writes the text "Hello @user1", the resulting hidden
   *                   text will be: "Hello @{user1 ; user1@pod.tld}. This is the text that is submitted
   *                   to the pod when the user posts.
   * this.elmMentionsOverlay: contains the text that will be displayed to the user
   *
   * this.mentionChar is a invisible caracter used to mark the name of the mentionned person
   * during the process. See this#processMention
   */
  initialize: function(){
    this.mentionsCollection = [];
    this.inputBuffer = [];
    this.currentDataQuery = "";
    this.mentionChar = "\u200B";

    this.elmInputBox = this.$el.find("#status_message_fake_text");
    var elmInputWrapper = this.elmInputBox.parent();
    this.elmInputBox.wrapAll($(this.settings.templates.wrapper()));
    var elmWrapperBox = elmInputWrapper.find("> div").first();
    this.elmMentionsOverlay = $(this.settings.templates.mentionsOverlay());
    this.elmMentionsOverlay.prependTo(elmWrapperBox);

    this.bindMentioningEvents();
    app.views.SearchBase.prototype.initialize.call(this, {typeaheadElement: this.getTypeaheadInput()});

    this.$el.find(".twitter-typeahead").css({position: "absolute", left: "-1px"});
    this.$el.find(".twitter-typeahead .tt-menu").css("margin-top", 0);
  },

  /**
   * Attach events to Typeahead.
   */
  bindMentioningEvents: function(){
    var self = this;
    // Process mention when the user selects a result.
    this.getTypeaheadInput().on("typeahead:select", function(evt, datum){
      self.processMention(datum);
      self.resetMentionBox();
      self.addToFilteredResults(datum);
    });

    // Highlight the first result when the results dropdown opens
    this.getTypeaheadInput().on("typeahead:render", function(){
      self.select(self.$(".tt-menu .tt-suggestion").first());
    });
  },

  clearBuffer: function(){
    this.inputBuffer.length = 0;
  },

  /**
   * Cleans the collection of mentionned people. Rejects every item who's name
   * is not present in the post an falsy values (false, null, "", etc.)
   */
  updateMentionsCollection: function(){
    var inputText = this.getInputBoxValue();

    this.mentionsCollection = _.reject(this.mentionsCollection, function(mention){
      return !mention.name || inputText.indexOf(mention.name) === -1;
    });
    this.mentionsCollection = _.compact(this.mentionsCollection);
  },

  /**
   * Adds mention to the mention collection
   * @param person Mentionned person.
   * JSON object of form { handle: <diaspora handle>, name: <name>, ... }
   */
  addMention: function(person){
    if(!person || !person.name || !person.handle){
      return;
    }
    // This is needed for processing preview
    /* jshint camelcase: false */
    person.diaspora_id = person.handle;
    /* jshint camelcase: true */
    this.mentionsCollection.push(person);
  },

  /**
   * Process the text to add mention to the post. Every @mention in the text
   * will be replaced by this.mentionChar + mention.name. This temporary text
   * will then be replaced by final syntax in this#updateValues
   *
   * For instance if the user types text "Hello @use" and selects result user1,
   * The text will be transformed to "Hello \u200Buser1" before calling this#updateValues
   *
   * @param mention Mentionned person.
   * JSON object of form { handle: <diaspora handle>, name: <name>, ... }
   */
  processMention: function(mention){
    var currentMessage = this.getInputBoxValue();

    var currentCaretPosition = this.getCaretPosition();
    var startCaretPosition = currentCaretPosition - (this.currentDataQuery.length + 1);

    // Extracts the text before the mention and the text after it.
    // startEndIndex is the position where to place the caret at the en of the process
    var start = currentMessage.substr(0, startCaretPosition);
    var end = currentMessage.substr(currentCaretPosition, currentMessage.length);
    var startEndIndex = (start + mention.name).length + 1;

    this.addMention(mention);

    // Cleaning before inserting the value, otherwise auto-complete would be triggered with "old" inputbuffer
    this.clearBuffer();
    this.currentDataQuery = "";
    this.resetMentionBox();

    // Autocompletes mention and updates message text
    var updatedMessageText = start + this.mentionChar + mention.name + end;
    this.elmInputBox.val(updatedMessageText);
    this.updateValues();

    // Set correct focus and caret position
    this.elmInputBox.focus();
    this.setCaretPosition(startEndIndex);
  },

  /**
   * Replaces every combination of this.mentionChar + mention.name by the
   * correct syntax for both hidden text and visible one.
   *
   * For instance, the text "Hello \u200Buser1" will be tranformed to
   * "Hello @{user1 ; user1@pod.tld}" in the hidden element and
   * "Hello <strong><span>user1</span></strong>" in the element visible to the user.
   */
  updateValues: function(){
    var syntaxMessage = this.getInputBoxValue();
    var mentionText = this.getInputBoxValue();
    this.clearFilteredResults();

    var self = this;

    _.each(this.mentionsCollection, function(mention){
      self.addToFilteredResults(mention);

      var mentionVal = self.mentionChar + mention.name;

      var textSyntax = self.settings.templates.mentionItemSyntax(mention);
      syntaxMessage = syntaxMessage.replace(mentionVal, textSyntax);

      var textHighlight = self.settings.templates.mentionItemHighlight({name: _.escape(mention.name)});
      mentionText = mentionText.replace(mentionVal, textHighlight);
    });

    mentionText = mentionText.replace(/\n/g, "<br/>");
    mentionText = mentionText.replace(/ {2}/g, "&nbsp; ");

    this.elmInputBox.data("messageText", syntaxMessage);
    this.elmMentionsOverlay.find("div > div").html(mentionText);
  },

  /**
   * Let us prefill the publisher with a mention list
   * @param persons List of people to mention in a post;
   * JSON object of form { handle: <diaspora handle>, name: <name>, ... }
   */
  prefillMention: function(persons){
    var self = this;
    _.each(persons, function(person){
      self.addMention(person);
      self.addToFilteredResults(person);
      var text = self.mentionChar + person.name;
      if(self.elmInputBox.val().length !== 0){
        text = self.elmInputBox.val() + " " + text;
      }
      self.elmInputBox.val(text);
      self.updateValues();
    });
  },

  /**
   * Selects next or previous result when result dropdown is open and
   * user press up and down arrows.
   */
  onArrowKeysPress: function(e){
    if(!this.isVisible() || (e.keyCode !== this.KEYS.UP && e.keyCode !== this.KEYS.DOWN)){
      return;
    }

    e.preventDefault();
    e.stopPropagation();

    this.getTypeaheadInput().typeahead("activate");
    this.getTypeaheadInput().typeahead("open");
    this.getTypeaheadInput().trigger($.Event("keydown", {keyCode: e.keyCode}));
  },

  onInputBoxKeyPress: function(e){
    // Excluding ctrl+v from key press event in firefox
    if(!((e.which === this.KEYS.PASTE && e.ctrlKey) || (e.keyCode === this.KEYS.BACKSPACE))){
      var typedValue = String.fromCharCode(e.which || e.keyCode);
      this.inputBuffer.push(typedValue);
    }
  },

  /**
   * Listens for user input and opens results dropdown when input contains the trigger char
   */
  onInputBoxInput: function(){
    this.updateValues();
    this.updateMentionsCollection();

    var triggerCharIndex = _.lastIndexOf(this.inputBuffer, this.settings.triggerChar);
    if(triggerCharIndex > -1){
      this.currentDataQuery = this.inputBuffer.slice(triggerCharIndex + 1).join("");
      this.currentDataQuery = this.rtrim(this.currentDataQuery);

      this.showMentionBox();
    }
  },

  onInputBoxKeyDown: function(e){
    // This also matches HOME/END on OSX which is CMD+LEFT, CMD+RIGHT
    if(e.keyCode === this.KEYS.LEFT || e.keyCode === this.KEYS.RIGHT ||
       e.keyCode === this.KEYS.HOME || e.keyCode === this.KEYS.END){
      _.defer(this.clearBuffer);

      // IE9 doesn't fire the oninput event when backspace or delete is pressed. This causes the highlighting
      // to stay on the screen whenever backspace is pressed after a highlighed word. This is simply a hack
      // to force updateValues() to fire when backspace/delete is pressed in IE9.
      if(navigator.userAgent.indexOf("MSIE 9") > -1){
        _.defer(this.updateValues);
      }

      return;
    }

    if(e.keyCode === this.KEYS.BACKSPACE){
      this.inputBuffer = this.inputBuffer.slice(0, this.inputBuffer.length - 1);
      return;
    }

    if(!this.isVisible){
      return true;
    }

    switch(e.keyCode){
      case this.KEYS.ESC:
      case this.KEYS.SPACE:
        this.resetMentionBox();
        break;
      case this.KEYS.UP:
      case this.KEYS.DOWN:
        this.onArrowKeysPress(e);
        break;
      case this.KEYS.RETURN:
      case this.KEYS.TAB:
        if(this.getSelected().size() === 1){
           this.getSelected().click();
          return false;
        }
        break;
    }
    return true;
  },

  onInputBoxClick: function(){
    this.resetMentionBox();
  },

  onInputBoxBlur: function(){
    this.resetMentionBox();
  },

  onInputBoxPaste: function(evt){
    var pastedData = evt.originalEvent.clipboardData.getData("text/plain");
    var dataArray = pastedData.split("");
    var self = this;
    _.each(dataArray, function(value){
      self.inputBuffer.push(value);
    });
  },

  reset: function(){
    this.elmInputBox.val("");
    this.mentionsCollection.length = 0;
    this.clearFilteredResults();
    this.updateValues();
  },

  showMentionBox: function(){
    this.getTypeaheadInput().typeahead("val", this.currentDataQuery);
    this.getTypeaheadInput().typeahead("open");
  },

  resetMentionBox: function(){
    this.getTypeaheadInput().typeahead("val", "");
    this.getTypeaheadInput().typeahead("close");
  },

  getInputBoxValue: function(){
    return $.trim(this.elmInputBox.val());
  },

  isVisible: function(){
    return this.$el.find(".tt-menu").is(":visible");
  },

  getTypeaheadInput: function(){
    if(this.$el.find(".typeahead-mention-box").length === 0){
      this.elmInputBox.after("<input class='typeahead-mention-box hidden' type='text'/>");
    }
    return this.$el.find(".typeahead-mention-box");
  },

  getTextForSubmit: function(){
    return this.mentionsCollection.length ? this.elmInputBox.data("messageText") : this.getInputBoxValue();
  },

  setCaretPosition: function(caretPos){
    this.elmInputBox[0].focus();
    this.elmInputBox[0].setSelectionRange(caretPos, caretPos);
  },

  getCaretPosition: function(){
    return this.elmInputBox[0].selectionStart;
  },

  rtrim: function(string){
    return string.replace(/\s+$/, "");
  }
});
