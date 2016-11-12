// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.SinglePostCommentStream = app.views.CommentStream.extend({
  tooltipSelector: "time, .control-icons a",

  initialize: function(){
    this.CommentView = app.views.ExpandedComment;
    $(window).on('hashchange',this.highlightPermalinkComment);
    this.setupBindings();
    this.model.comments.fetch({success: function() {
      setTimeout(this.highlightPermalinkComment, 0);
    }.bind(this)});
  },

  highlightPermalinkComment: function() {
    if (document.location.hash && $(document.location.hash).length > 0) {
      var element = $(document.location.hash);
      var headerSize = 60;
      $(".highlighted").removeClass("highlighted");
      element.addClass("highlighted");
      var pos = element.offset().top - headerSize;
      $("html,body").animate({scrollTop: pos});
    }
  },

  postRenderTemplate: function() {
    app.views.CommentStream.prototype.postRenderTemplate.apply(this);
    this.$(".new-comment-form-wrapper").removeClass("hidden");
  },

  presenter: function(){
    return _.extend(this.defaultPresenter(), {
      moreCommentsCount : 0,
      showExpandCommentsLink : false,
      commentsCount : this.model.interactions.commentsCount()
    });
  },
});
// @license-end
