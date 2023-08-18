// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.SinglePostCommentStream = app.views.CommentStream.extend({
  tooltipSelector: "time, .control-icons a",

  initialize: function(){
    this.CommentView = app.views.ExpandedComment;
    $(window).on("hashchange", this.highlightPermalinkComment.bind(this));
    this.setupBindings();
  },

  highlightPermalinkComment: function() {
    if (!document.location.hash) {
      return;
    }

    var selector = document.location.hash;

    if (this.$(selector).length === 0) {
      this.once("commentsExpanded", function() { _.defer(this.highlightComment, selector); });
      this.expandComments();
    } else {
      this.highlightComment(selector);
    }
  },

  highlightComment: function(selector) {
    if (this.$(selector).length === 0) {
      return;
    }

    var element = this.$(selector);
    var headerSize = $("nav.navbar-fixed-top").height() + 10;
    this.$(".highlighted").removeClass("highlighted");
    element.addClass("highlighted");
    var pos = element.offset().top - headerSize;
    window.scroll(0, pos);
  },

  postRenderTemplate: function() {
    app.views.CommentStream.prototype.postRenderTemplate.apply(this);
    this.$(".new-comment-form-wrapper").removeClass("hidden");
    _.defer(this.highlightPermalinkComment.bind(this));
  }
});
// @license-end
