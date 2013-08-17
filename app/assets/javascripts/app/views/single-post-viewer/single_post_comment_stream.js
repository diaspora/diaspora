app.views.SinglePostCommentStream = app.views.CommentStream.extend({

  postRenderTemplate: function() {
    app.views.CommentStream.prototype.postRenderTemplate.apply(this)
    this.$(".new_comment_form_wrapper").removeClass('hidden')
  },

  presenter: function(){
    return _.extend(this.defaultPresenter(), {
      moreCommentsCount : 0,
      showExpandCommentsLink : false,
      commentsCount : this.model.interactions.commentsCount()
    })
  },
})
