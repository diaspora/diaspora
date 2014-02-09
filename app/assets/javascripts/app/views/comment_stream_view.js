app.views.CommentStream = app.views.Base.extend({
  _commentViews: [],
  _selectedComment: -1,
  _headerSize: 50,
  templateName: "comment-stream",

  className : "comment_stream",

  events: {
    "keydown .comment_box": "keyDownOnCommentBox",
    "submit form": "createComment",
    "focus .comment_box": "commentTextareaFocused",
    "click .toggle_post_comments": "expandComments"
  },

  initialize: function(options) {
    this.commentTemplate = options.commentTemplate;

    this.setupBindings();
  },

  setupBindings: function() {
    this.model.comments.bind('add', this.appendComment, this);
    this.model.bind("commentsExpanded", this.render, this);
  },

  postRenderTemplate : function() {
    this.$("textarea").placeholder();
    this.model.comments.each(this.appendComment, this);

    // add autoexpanders to new comment textarea
    this.$("textarea").autoResize({'extraSpace' : 10});
  },

  presenter: function(){
    return _.extend(this.defaultPresenter(), {
      moreCommentsCount : (this.model.interactions.commentsCount() - 3),
      showExpandCommentsLink : (this.model.interactions.commentsCount() > 3),
      commentsCount : this.model.interactions.commentsCount()
    });
  },

  createComment: function(evt) {
    if(evt){ evt.preventDefault(); }
    
    var commentText = $.trim(this.$('.comment_box').val());
    this.$(".comment_box").val("");
    this.$(".comment_box").css("height", "");
    if(commentText) {
      this.model.comment(commentText);
      return this;
    } else {
      this.$(".comment_box").focus();
    }
  },

  keyDownOnCommentBox: function(evt) {
    if(evt.keyCode == 13 && evt.ctrlKey) {
      this.$("form").submit();
      return false;
    }
  },
  
  appendComment: function(comment) {
    // Set the post as the comment's parent, so we can check
    // on post ownership in the Comment view.
    comment.set({parent : this.model.toJSON()});
   
    var commentView = new app.views.Comment({
      model: comment
    });

    this.$(".comments").append(commentView.render().el);
    this._commentViews.push(commentView);
  },

  commentTextareaFocused: function(evt){
    this.$("form").removeClass('hidden').addClass("open");
  },

  expandComments: function(evt){
    if(evt){ evt.preventDefault(); }

    self = this;

    this.model.comments.fetch({
      success : function(resp){
        self.model.set({
          comments : resp.models,
          all_comments_loaded : true
        });

        self.model.trigger("commentsExpanded", self);
      }
    });
  },

  deselectComment: function() {
    this._selectedComment = -1;
    var selected = this.$('div.comment.shortcut_selected');
    selected.removeClass('shortcut_selected').removeClass('highlighted');
  },

  selectNextComment: function() {
    if (++this._selectedComment == this.model.comments.length) {
      this._selectedComment = this.model.comments.length-1;
    }
    this.selectComment(this._selectedComment);
  },

  selectPrevComment: function() {
    if (--this._selectedComment < 0) {
      this._selectedComment = 0;
    } 
    this.selectComment(this._selectedComment);
  },

  selectComment: function(index) {
    this._selectedComment = index;
    this.listenToOnce(this.model,'commentsExpanded', function() {
      //long comments are collapsed (see comment_view.js postRenderTemplate) we need to wait for that before expand them again
      _.defer(_.bind(function() {
      	$(this._commentViews).each(function(index, commentView) {
      		var expander = commentView.$el.find('.expander');
      		expander.trigger('expandWithoutAnimation');
      	});
      }, this));
      
      //wait for expanding long comments then select the comment
      _.defer(_.bind(function() {
        var element =  this.$el.find('.comment').get(this._selectedComment);
        $(element).addClass('shortcut_selected highlighted');
        window.scrollTo(window.pageXOffset, element.offsetTop-this._headerSize);  
      }, this));
    });
    
    
    this.expandComments();
  }
});
