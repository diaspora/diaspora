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

  initialize: function(){
    this.mentionsCollection = [];
    this.inputBuffer = [];
    this.currentDataQuery = "";
    this.mentionChar = "\u200B";

    this.elmInputBox = this.$el.find("#status_message_fake_text");
    this.elmInputWrapper = this.elmInputBox.parent();
    this.elmWrapperBox = $(this.settings.templates.wrapper());
    this.elmInputBox.wrapAll(this.elmWrapperBox);
    this.elmWrapperBox = this.elmInputWrapper.find("> div").first();
    this.elmMentionsOverlay = $(this.settings.templates.mentionsOverlay());
    this.elmMentionsOverlay.prependTo(this.elmWrapperBox);

    this.bindMentionningEvents();
    this.completeSetup(this.getTypeaheadInput());

    this.$el.find(".twitter-typeahead").css({position: "absolute", left: "-1px"});
    this.$el.find(".twitter-typeahead .tt-menu").css("margin-top", 0);
  },

  bindMentionningEvents: function(){
    var self = this;
    this.getTypeaheadInput().on("typeahead:select", function(evt, datum){
      self.processMention(datum);
      self.resetMentionBox();
      self.addToFilteredResults(datum);
    });

    this.getTypeaheadInput().on("typeahead:render", function(){
      self.select(self.$(".tt-menu .tt-suggestion").first());
    });
  },

  clearBuffer: function(){
    this.inputBuffer.length = 0;
  },

  updateMentionsCollection: function(){
    var inputText = this.getInputBoxValue();

    this.mentionsCollection = _.reject(this.mentionsCollection, function(mention){
      return !mention.name || inputText.indexOf(mention.name) === -1;
    });
    this.mentionsCollection = _.compact(this.mentionsCollection);
  },

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

  processMention: function(mention){
    var currentMessage = this.getInputBoxValue();

    var currentCaretPosition = this.getCaretPosition();
    var startCaretPosition = currentCaretPosition - (this.currentDataQuery.length + 1);

    var start = currentMessage.substr(0, startCaretPosition);
    var end = currentMessage.substr(currentCaretPosition, currentMessage.length);
    var startEndIndex = (start + mention.name).length + 1;

    this.addMention(mention);

    // Cleaning before inserting the value, otherwise auto-complete would be triggered with "old" inputbuffer
    this.clearBuffer();
    this.currentDataQuery = "";
    this.resetMentionBox();

    // Mentions & syntax message
    var updatedMessageText = start + this.mentionChar + mention.name + end;
    this.elmInputBox.val(updatedMessageText);
    this.updateValues();

    // Set correct focus and selection
    this.elmInputBox.focus();
    this.setCaretPosition(startEndIndex);
  },

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

  selectNextResult: function(evt){
    if(this.isVisible()){
      evt.preventDefault();
      evt.stopPropagation();
    }

    if(this.getSelected().size() !== 1 || this.getSelected().next().size() !== 1){
      this.getSelected().removeClass("tt-cursor");
      this.$el.find(".tt-suggestion").first().addClass("tt-cursor");
    }
    else{
      this.getSelected().removeClass("tt-cursor").next().addClass("tt-cursor");
    }
  },

  selectPreviousResult: function(evt){
    if(this.isVisible()){
      evt.preventDefault();
      evt.stopPropagation();
    }

    if(this.getSelected().size() !== 1 || this.getSelected().prev().size() !== 1){
      this.getSelected().removeClass("tt-cursor");
      this.$el.find(".tt-suggestion").last().addClass("tt-cursor");
    }
    else{
      this.getSelected().removeClass("tt-cursor").prev().addClass("tt-cursor");
    }
  },

  onInputBoxKeyPress: function(e){
    // Excluding ctrl+v from key press event in firefox
    if(!((e.which === this.KEYS.PASTE && e.ctrlKey) || (e.keyCode === this.KEYS.BACKSPACE))){
      var typedValue = String.fromCharCode(e.which || e.keyCode);
      this.inputBuffer.push(typedValue);
    }
  },

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
        this.selectPreviousResult(e);
        break;
      case this.KEYS.DOWN:
        this.selectNextResult(e);
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
