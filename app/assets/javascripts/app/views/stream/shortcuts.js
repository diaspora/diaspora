// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.StreamShortcuts = Backbone.View.extend({
  _headerSize: 60,

  events: {
    "keydown": "_onHotkeyDown",
    "keyup": "_onHotkeyUp"
  },

  _onHotkeyDown: function(event) {
    //make sure that the user is not typing in an input field
    var textAcceptingInputTypes = ["textarea", "select", "text", "password", "number", "email", "url", "range", "date", "month", "week", "time", "datetime", "datetime-local", "search", "color"];
    if(jQuery.inArray(event.target.type, textAcceptingInputTypes) > -1){
      return;
    }

    // trigger the events based on what key was pressed
    switch (String.fromCharCode( event.which ).toLowerCase()) {
      case "j":
        this.gotoNext();
        break;
      case "k":
        this.gotoPrev();
        break;
      default:
    }
  },

  _onHotkeyUp: function(event) {
    //make sure that the user is not typing in an input field
    var textAcceptingInputTypes = ["textarea", "select", "text", "password", "number", "email", "url", "range", "date", "month", "week", "time", "datetime", "datetime-local", "search", "color"];
    if(jQuery.inArray(event.target.type, textAcceptingInputTypes) > -1){
      return;
    }

    // trigger the events based on what key was pressed
    switch (String.fromCharCode( event.which ).toLowerCase()) {
      case "c":
        this.commentSelected();
        break;
      case "l":
        this.likeSelected();
        break;
      case "r":
        this.reshareSelected();
        break;
      case "m":
        this.expandSelected();
        break;
      case "o":
        this.openFirstLinkSelected();
        break;
      default:
    }
  },

  gotoNext: function() {
    // select next post: take the first post under the header
    var streamElements = this.$("div.stream-element.loaded");
    var posUser = window.pageYOffset;

    for (var i = 0; i < streamElements.length; i++) {
      if (Math.round($(streamElements[i]).offset().top) > posUser + this._headerSize) {
        this.selectPost(streamElements[i]);
        return;
      }
    }
    // standard: last post
    if (streamElements[streamElements.length - 1]) {
      this.selectPost(streamElements[streamElements.length - 1]);
    }
  },

  gotoPrev: function() {
    // select previous post: take the first post above the header
    var streamElements = this.$("div.stream-element.loaded");
    var posUser = window.pageYOffset;

    for (var i = streamElements.length - 1; i >= 0; i--) {
      if (Math.round($(streamElements[i]).offset().top) < posUser + this._headerSize) {
        this.selectPost(streamElements[i]);
        return;
      }
    }
    // standard: first post
    if (streamElements[0]) {
      this.selectPost(streamElements[0]);
    }
  },

  commentSelected: function() {
    $('a.focus_comment_textarea',this.$('div.stream-element.loaded.shortcut_selected')).click();
  },

  likeSelected: function() {
    $('a.like:first',this.$('div.stream-element.loaded.shortcut_selected')).click();
  },

  reshareSelected: function() {
    $('a.reshare:first',this.$('div.stream-element.loaded.shortcut_selected')).click();
  },

  expandSelected: function() {
    $('div.expander:first',this.$('div.stream-element.loaded.shortcut_selected')).click();
  },

  openFirstLinkSelected: function() {
    var link = $('div.collapsible a[target="_blank"]:first',this.$('div.stream-element.loaded.shortcut_selected'));
    if(link.length > 0) {
      // click does only work with vanilla javascript
      link[0].click();
    }
  },

  selectPost: function(element){
    //remove the selection and selected-class from all posts
    var selected=this.$('div.stream-element.loaded.shortcut_selected');
    selected.removeClass('shortcut_selected').removeClass('highlighted');
    //move to new post
    window.scrollTo(window.pageXOffset, Math.round($(element).offset().top - this._headerSize));
    //add the selection and selected-class to new post
    element.className+=" shortcut_selected highlighted";
  },
});
// @license-end
