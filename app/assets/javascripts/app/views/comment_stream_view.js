// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.CommentStream = app.views.Base.extend({

  templateName: "comment-stream",

  className : "comment_stream",

  events: {
    "keydown .comment_box": "keyDownOnCommentBox",
    "submit form": "createComment",
    "focus .comment_box": "commentTextareaFocused",
    "click .toggle_post_comments": "expandComments"
  },

  initialize: function() {
    this.CommentView = app.views.Comment;
    this.setupBindings();
  },

  setupBindings: function() {
    this.model.comments.bind("add", this.appendComment, this);
    this.model.comments.bind("remove", this.removeComment, this);
  },

  postRenderTemplate : function() {
    this.model.comments.each(this.appendComment, this);
    this.commentBox = this.$(".comment_box");
    this.commentSubmitButton = this.$("input[name='commit']");
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

    var commentText = $.trim(this.commentBox.val());
    if (commentText === "") {
      this.commentBox.focus();
      return;
    }

    this.disableCommentBox();

    this.model.comment(commentText, {
      success: function() {
        this.commentBox.val("");
        this.enableCommentBox();
        autosize.update(this.commentBox);
      }.bind(this),
      error: function() {
        this.enableCommentBox();
        this.commentBox.focus();
      }.bind(this)
    });
  },

  disableCommentBox: function() {
    this.commentBox.prop("disabled", true);
    this.commentSubmitButton.prop("disabled", true);
  },

  enableCommentBox: function() {
    this.commentBox.removeAttr("disabled");
    this.commentSubmitButton.removeAttr("disabled");
  },

  keyDownOnCommentBox: function(evt) {
    if(evt.which === Keycodes.ENTER && evt.ctrlKey) {
      this.$("form").submit();
      return false;
    }
  },

  _insertPoint: 0, // An index of the comment added in the last call of this.appendComment

  // This adjusts this._insertPoint according to timestamp value
  _moveInsertPoint: function(timestamp, commentBlocks) {
    if (commentBlocks.length === 0) {
      this._insertPoint = 0;
      return;
    }

    if (this._insertPoint > commentBlocks.length) {
      this._insertPoint = commentBlocks.length;
    }

    while (this._insertPoint > 0 && timestamp < commentBlocks.eq(this._insertPoint - 1).find("time").attr("datetime")) {
      this._insertPoint--;
    }
    while (this._insertPoint < commentBlocks.length &&
        timestamp > commentBlocks.eq(this._insertPoint).find("time").attr("datetime")) {
      this._insertPoint++;
    }
  },

  appendComment: function(comment) {
    // Set the post as the comment's parent, so we can check
    // on post ownership in the Comment view.
    comment.set({parent : this.model.toJSON()});

    var commentHtml = new this.CommentView({model: comment}).render().el;
    var commentBlocks = this.$(".comments div.comment.media");
    this._moveInsertPoint(comment.get("created_at"), commentBlocks);
    if (this._insertPoint >= commentBlocks.length) {
      this.$(".comments").append(commentHtml);
    } else if (this._insertPoint <= 0) {
      this.$(".comments").prepend(commentHtml);
    } else {
      commentBlocks.eq(this._insertPoint).before(commentHtml);
    }
  },

  removeComment: function(comment) {
    this.$("#" + comment.get("guid")).closest(".comment.media").remove();
  },

  commentTextareaFocused: function(){
    this.$("form").removeClass('hidden').addClass("open");
  },

  expandComments: function(evt){
    this.$(".loading-comments").removeClass("hidden");
    if(evt){ evt.preventDefault(); }
    this.model.comments.fetch({
      success: function() {
        this.$("div.comment.show_comments").addClass("hidden");
        this.$(".loading-comments").addClass("hidden");
      }.bind(this)
    });
  }
});
// @license-end
