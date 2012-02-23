app.views.PostViewerFeedback = app.views.Feedback.extend({

  id : "user-controls",
  className : "",

  templateName: "post-viewer/feedback",

  events : {
    "click .like" : "toggleLike",
    "click .follow" : "toggleFollow",
    "click .reshare" : "resharePost",

    "click .comment" : "invokePane"
  },

  tooltipSelector : ".label",

  invokePane : function(evt){
    this.trigger("invokePane")
  }

})
