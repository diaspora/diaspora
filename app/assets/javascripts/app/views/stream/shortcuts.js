// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.StreamShortcuts = {

  _headerSize: 50,


  setupShortcuts : function() {
    $(document).on('keydown', _.bind(this._onHotkeyDown, this));
    $(document).on('keyup', _.bind(this._onHotkeyUp, this));

    this.on('hotkey:gotoNext', this.gotoNext, this);
    this.on('hotkey:gotoPrev', this.gotoPrev, this);
    this.on('hotkey:likeSelected', this.likeSelected, this);
    this.on('hotkey:commentSelected', this.commentSelected, this);
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
        this.trigger('hotkey:gotoNext');
        break;
      case "k":
        this.trigger('hotkey:gotoPrev');
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
        this.trigger('hotkey:commentSelected');
        break;
      case "l":
        this.trigger('hotkey:likeSelected');
        break;
      default:
    }
  },

  gotoNext: function() {
    // select next post: take the first post under the header
    var stream_elements = this.$('div.stream_element.loaded');
    var posUser = window.pageYOffset;
     
    for (var i = 0; i < stream_elements.length; i++) {
      if(stream_elements[i].offsetTop>posUser+this._headerSize){
        this.selectPost(stream_elements[i]);
        return;
      }
    }
    // standard: last post
    if(stream_elements[stream_elements.length-1]){
      this.selectPost(stream_elements[stream_elements.length-1]);
    }
  },

  gotoPrev: function() {
    // select previous post: take the first post above the header
    var stream_elements = this.$('div.stream_element.loaded');
    var posUser = window.pageYOffset;
      
    for (var i = stream_elements.length-1; i >=0; i--) {
      if(stream_elements[i].offsetTop<posUser+this._headerSize){
        this.selectPost(stream_elements[i]);
        return;
      }
    }
    // standard: first post
    if(stream_elements[0]){
      this.selectPost(stream_elements[0]);
    }
  },
    
  commentSelected: function() {
    $('a.focus_comment_textarea',this.$('div.stream_element.loaded.shortcut_selected')).click();
  },    
    
  likeSelected: function() {
    $('a.like:first',this.$('div.stream_element.loaded.shortcut_selected')).click();
  },
    
  selectPost: function(element){
    //remove the selection and selected-class from all posts
    var selected=this.$('div.stream_element.loaded.shortcut_selected');
    selected.removeClass('shortcut_selected').removeClass('highlighted');
    //move to new post
    window.scrollTo(window.pageXOffset, element.offsetTop-this._headerSize);
    //add the selection and selected-class to new post
    element.className+=" shortcut_selected highlighted";	
  },
};
// @license-end

