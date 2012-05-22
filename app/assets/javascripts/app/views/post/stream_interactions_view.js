app.views.StreamInteractions = app.views.Base.extend({
  id : "post-info",

  subviews:{
    ".comments" : "comments",
    ".new-comment" : "newCommentView"
  },

  templateName : "stream-interactions",

  setInteractions : function (model) {
    model.interactions.fetch().done(
      _.bind(function () {
        this.render()
      }, this));

    this.comments = new app.views.PostViewerReactions({ model: model.interactions })
    this.newCommentView = new app.views.PostViewerNewComment({ model : model })
  }
});
