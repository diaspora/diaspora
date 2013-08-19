app.views.SinglePostCommentStream = app.views.CommentStream.extend({
  tooltipSelector: "time, .controls a",

  postRenderTemplate: function() {
    app.views.CommentStream.prototype.postRenderTemplate.apply(this)
    this.$(".new_comment_form_wrapper").removeClass('hidden')
  },

  appendComment: function(comment) {
    // Set the post as the comment's parent, so we can check
    // on post ownership in the Comment view.
    comment.set({parent : this.model.toJSON()})

    this.$(".comments").append(new app.views.ExpandedComment({
      model: comment
    }).render().el);
  },

  presenter: function(){
    return _.extend(this.defaultPresenter(), {
      moreCommentsCount : 0,
      showExpandCommentsLink : false,
      commentsCount : this.model.interactions.commentsCount()
    })
  },
})
