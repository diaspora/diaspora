//= require ../feedback_view

app.views.PostViewerFeedback = app.views.Feedback.extend({
  id : "user-controls",
  className : "",

  templateName: "post-viewer/feedback",

  subviews : {
    ".feedback-actions" : "feedbackActions"
  },


  initViews : function(){
    this.feedbackActions = new app.views.FeedbackActions({model : this.model})
  },
});
