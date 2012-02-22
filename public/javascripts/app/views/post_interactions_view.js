app.views.PostViewerInteractions = app.views.Base.extend({

  className : "",

  subviews : {
    "#post-feedback" : "feedbackView",
    "#post-reactions" : "reactionsView"
  },

  templateName: "post-viewer/interactions",

  feedbackView : function() {
    if(!window.app.user()) { return null }
    return new app.views.PostViewerFeedback({ model : this.model })
  },

  reactionsView : function() {
    if(!window.app.user()) { return null }
    return new app.views.PostViewerReactions({ model : this.model })
  }
})
