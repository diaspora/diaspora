app.views.PostViewerFeedback = app.views.Feedback.extend({

  id : "user-controls",
  className : "",

  templateName: "post-viewer/feedback",

  events : {
    "click .like" : "toggleLike",
    "click .follow" : "toggleFollow",
    "click .reshare" : "resharePost",

    "click *[rel='invoke-interaction-pane']" : "invokePane",
    "click *[rel='hide-interaction-pane']" : "hidePane"
  },

  tooltipSelector : ".label",

  invokePane : function(evt){ this.trigger("invokePane") },
  hidePane : function(evt){ this.trigger("hidePane") }

})
