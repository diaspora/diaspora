app.views.PostViewerInteractions = app.views.Base.extend({

  className : "",

  subviews : {
    "#post-feedback" : "feedbackView",
    "#post-reactions" : "reactionsView",
    "#new-post-comment" : "newCommentView"
  },

  templateName: "post-viewer/interactions",

  feedbackView : function() {
    if(!window.app.user()) { return null }
    return new app.views.PostViewerFeedback({ model : this.model })
  },

  reactionsView : function() {
    return new app.views.PostViewerReactions({ model : this.model })
  },

  newCommentView : function() {
    if(!window.app.user()) { return null }
    return new app.views.PostViewerNewComment({ model : this.model })
  }
})
