app.views.StreamInteractions = app.views.Base.extend({
  subviews : {
    ".feedback" : "feedback",
    ".comments" : "comments"
  },

  templateName : "stream-interactions",

  initialize : function(){
    this.feedback = new app.views.FeedbackActions({ model : this.model })
    this.comments = new app.views.PostViewerFeedback({ model : this.model })
  }
})