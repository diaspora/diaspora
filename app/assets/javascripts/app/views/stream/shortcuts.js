app.views.StreamShortcuts = {

  _headerSize: 50,


  setupShortcuts : function() {
    $(document).on('keydown', _.bind(this._onHotkeyDown, this));
    $(document).on('keyup', _.bind(this._onHotkeyUp, this));

    this.on('hotkey:gotoNext', this.gotoNext, this);
    this.on('hotkey:gotoPrev', this.gotoPrev, this);
    this.on('hotkey:gotoNextComment', this.gotoNextComment, this);
    this.on('hotkey:gotoPrevComment', this.gotoPrevComment, this);
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
      case "n":
        this.trigger('hotkey:gotoNextComment');
        break;
      case "p":
        this.trigger('hotkey:gotoPrevComment');
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

  _getSelectedPost: function() {
     return this.$('div.stream_element.loaded.shortcut_selected');
  },

  _getComments: function(post) {
    return post.find('div.comment_stream > div.comments > div.comment');
  },

  _getSelectedCommentIndex: function(comments) {
    var selectedCommentIndex = -1;
    comments.each(function(index, element) {
      if ($(element).hasClass('shortcut_selected')) {
        selectedCommentIndex = index;
      }
    });
    return selectedCommentIndex;
  },

  gotoNextComment: function() {
    //TODO index > size expand hidden comments prev comment
    var selectedPost = this._getSelectedPost();
    if (selectedPost.length > 0) {
      var comments = this._getComments(selectedPost);
      var selectedCommentIndex = this._getSelectedCommentIndex(comments);
      if (selectedCommentIndex < 0) {
        this.selectComment(comments.get(0));
      } else if (selectedCommentIndex == comments.length-1) {
        // do nothing, maybe next comment in next post?
      } else {
        this.selectComment(comments.get(selectedCommentIndex + 1));
      }
    } else {
      //no post selected
    }
  },

  gotoPrevComment: function() {
    //TODO index > size expand hidden comments prev comment
    var selectedPost = this._getSelectedPost();
    if (selectedPost.length > 0) {
      var comments = this._getComments(selectedPost);
      var selectedCommentIndex = this._getSelectedCommentIndex(comments);
      if (selectedCommentIndex < 0) {
        this.selectComment(comments.get(0));
      } else if (selectedCommentIndex < 1) {
        // do nothing, mybe select comment in previous post?
      } else {
        this.selectComment(comments.get(selectedCommentIndex -1));
      }
    } else {
      //no post selected
    }
  },

  commentSelected: function() {
    $('a.focus_comment_textarea',this.$('div.stream_element.loaded.shortcut_selected')).click();
  },    
    
  likeSelected: function() {
    $('a.like:first',this.$('div.stream_element.loaded.shortcut_selected')).click();
  },
    
  selectPost: function(element) {
    this._deselectComments();
    //remove the selection and selected-class from all posts
    var selected=this.$('div.stream_element.loaded.shortcut_selected');
    selected.removeClass('shortcut_selected').removeClass('highlighted');
    //move to new post
    window.scrollTo(window.pageXOffset, element.offsetTop-this._headerSize);
    //add the selection and selected-class to new post
    element.className+=" shortcut_selected highlighted";
    //post element can listen to keybord in put now
    $(element).attr('tabindex','0').focus();
  },

  _deselectComments: function() {
    //remove the selection and selected-class from all comments
    var selected=this.$('div.comment.shortcut_selected');
    selected.removeClass('shortcut_selected').removeClass('highlighted');
  },

  selectComment: function(element) {
    this._deselectComments();
    //move to new post
    window.scrollTo(window.pageXOffset, element.offsetTop-this._headerSize);
    //add the selection and selected-class to new post
    element.className+=" shortcut_selected highlighted";
  }
};
