app.views.PostViewerFeedback = app.views.Feedback.extend({

  id : "user-controls",
  className : "",

  templateName: "post-viewer/feedback",

  events : {
    "click .like" : "toggleLike",
    "click .follow" : "toggleFollow",
    "click .reshare" : "resharePost",

    "click .comment" : "comment"
  },

  tooltipSelector : ".label",

  comment : function(evt){
    if(evt) { evt.preventDefault() }
    $("#post-info").slideToggle()

    this.removeTooltips()
    console.log(this.model)
  }

})
