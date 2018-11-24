// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.CommentStream = app.views.Base.extend({

  templateName: "comment-stream",

  className : "comment_stream",

  events: {
    "keydown .comment-box": "keyDownOnCommentBox",
    "submit form": "createComment",
    "click .toggle_post_comments": "expandComments",
    "click form": "openForm"
  },

  initialize: function() {
    this.CommentView = app.views.Comment;
    this.setupBindings();
  },

  setupBindings: function() {
    this.model.comments.bind("add", this.appendComment, this);
    this.model.comments.bind("remove", this.removeComment, this);
    $(document.body).click(this.onFormBlur.bind(this));
  },

  postRenderTemplate : function() {
    this.model.comments.each(this.appendComment, this);
    this.commentBox = this.$(".comment-box");
    this.commentSubmitButton = this.$("input[name='commit']");
    this.mentions = new app.views.CommentMention({el: this.$el, postId: this.model.get("id")});

    this.mdEditor = new Diaspora.MarkdownEditor(this.$(".comment-box"), {
      onPreview: function($mdInstance) {
        var renderedText = app.helpers.textFormatter($mdInstance.getContent(), this.mentions.getMentionedPeople());
        return "<div class='preview-content'>" + renderedText + "</div>";
      }.bind(this),
      onFocus: this.openForm.bind(this)
    });

    this.$("form").areYouSure();
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
        this.mdEditor.hidePreview();
        this.closeForm();
        autosize.update(this.commentBox);
      }.bind(this),
      error: function() {
        this.enableCommentBox();
        this.mdEditor.hidePreview();
        this.openForm();
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
    if (evt.which === Keycodes.ENTER && (evt.metaKey || evt.ctrlKey)) {
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

    var commentView = new this.CommentView({model: comment});
    var commentHtml = commentView.render().el;
    var commentBlocks = this.$(".comments div.comment.media");
    this._moveInsertPoint(comment.get("created_at"), commentBlocks);
    if (this._insertPoint >= commentBlocks.length) {
      this.$(".comments").append(commentHtml);
    } else if (this._insertPoint <= 0) {
      this.$(".comments").prepend(commentHtml);
    } else {
      commentBlocks.eq(this._insertPoint).before(commentHtml);
    }
    commentView.renderPluginWidgets();
  },

  removeComment: function(comment) {
    var result = this.$("#" + comment.get("guid")).closest(".comment.media").remove();
    if (result.hasClass("deleting")) {
      this.model.interactions.removedComment();
    }
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
  },

  openForm: function() {
    this.$("form").addClass("open");
    this.$(".md-editor").addClass("active");
  },

  closeForm: function() {
    this.$("form").removeClass("open");
    this.$(".md-editor").removeClass("active");
    this.commentBox.blur();
    autosize.update(this.commentBox);
  },

  isCloseAllowed: function() {
    if (this.mdEditor === undefined) {
      return true;
    }
    return !this.mdEditor.isPreviewMode() && this.mdEditor.userInputEmpty();
  },

  onFormBlur: function(evt) {
    if (!this.isCloseAllowed()) {
      return;
    }

    var $target = $(evt.target);
    var isForm = $target.hasClass("new-comment") || $target.parents(".new-comment").length !== 0;
    if (!isForm && !$target.hasClass("focus_comment_textarea")) {
      this.closeForm();
    }
  }
});
// @license-end
