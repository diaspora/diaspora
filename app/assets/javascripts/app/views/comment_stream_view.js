app.views.CommentStream = app.views.Base.extend({

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
    this.model.bind("commentsExpanded", this.storeTextareaValue, this);
    this.model.bind("commentsExpanded", this.render, this);
  },

  postRenderTemplate : function() {
    this.$("textarea").placeholder();
    this.model.comments.each(this.appendComment, this);

    // add autoexpanders to new comment textarea
    this.$("textarea").autoResize({'extraSpace' : 10});
    this.$('textarea').val(this.textareaValue);
  },

  presenter: function(){
    return _.extend(this.defaultPresenter(), {
      moreCommentsCount : (this.model.interactions.commentsCount() - 3),
      showExpandCommentsLink : (this.model.interactions.commentsCount() > 3),
      commentsCount : this.model.interactions.commentsCount()
    })
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
      this.$("form").submit()
      return false;
    }
  },
  
  appendComment: function(comment) {
    // Set the post as the comment's parent, so we can check
    // on post ownership in the Comment view.
    comment.set({parent : this.model.toJSON()})

    this.$(".comments").append(new app.views.Comment({
      model: comment
    }).render().el);
  },

  commentTextareaFocused: function(evt){
    this.$("form").removeClass('hidden').addClass("open");
  },

  storeTextareaValue: function(){
    this.textareaValue = this.$('textarea').val();
  },

  expandComments: function(evt){
    if(evt){ evt.preventDefault(); }

    self = this;

    this.model.comments.fetch({
      success : function(resp){
        self.model.set({
          comments : resp.models,
          all_comments_loaded : true
        })

        self.model.trigger("commentsExpanded", self)
      }
    });
  }
});
