app.views.PostViewerFeedback = app.views.Feedback.extend({

  id : "user-controls",
  className : "",

  templateName: "post-viewer/feedback",

  events : {
    "click .like" : "toggleLike",
    "click .follow" : "toggleFollow",
    "click .reshare" : "resharePost",

    "click *[rel='interaction-pane']" : "invokePane"
  },

  tooltipSelector : ".label",

  invokePane : function(evt){
    this.trigger("invokePane")
  }
})
