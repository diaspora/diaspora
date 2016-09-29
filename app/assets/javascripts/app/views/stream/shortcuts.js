// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.StreamShortcuts = Backbone.View.extend({
  _headerSize: 60,

  initialize: function() {
    app.helpers.Shortcuts("keydown", this._onHotkeyDown.bind(this));
    app.helpers.Shortcuts("keyup", this._onHotkeyUp.bind(this));
  },

  _onHotkeyDown: function(event) {
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
    this.shortcutSelected().find("a.focus_comment_textarea").click();
  },

  likeSelected: function() {
    this.shortcutSelected().find("a.like:first").click();
  },

  reshareSelected: function() {
    this.shortcutSelected().find("a.reshare:first").click();
  },

  expandSelected: function() {
    this.shortcutSelected().find("div.expander:first").click();
  },

  shortcutSelected: function() {
    return this.$("div.stream-element.loaded.shortcut_selected");
  },

  openFirstLinkSelected: function() {
    var link = $("div.collapsible a[target='_blank']:first");
    if(link.length > 0) {
      // click does only work with vanilla javascript
      link[0].click();
    }
  },

  selectPost: function(element){
    //remove the selection and selected-class from all posts
    this.shortcutSelected().removeClass("shortcut_selected").removeClass("highlighted");
    //move to new post
    window.scrollTo(window.pageXOffset, Math.round($(element).offset().top - this._headerSize));
    //add the selection and selected-class to new post
    element.className+=" shortcut_selected highlighted";
  }
});
// @license-end
