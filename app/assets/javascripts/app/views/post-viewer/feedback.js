//= require ../feedback_view

app.views.PostViewerFeedback = app.views.Feedback.extend({
  id : "user-controls",
  className : "",

  templateName: "post-viewer/feedback",

  subviews : {
    ".feedback-actions" : "feedbackActions"
  },

  events :_.extend({}, app.views.Feedback.prototype.events, {
    "click *[rel='invoke-interaction-pane']" : "invokePane",
    "click *[rel='hide-interaction-pane']" : "hidePane"
  }),

  initViews : function(){
    this.feedbackActions = new app.views.FeedbackActions({model : this.model})
  },

  postRenderTemplate : function() {
    this.sneakyVisiblity()
  },

  sneakyVisiblity : function() {
    if(!$("#post-info").is(":visible")) {
      this.$("#post-info-sneaky").removeClass('passive')
    }
  },

  invokePane : function(evt){ this.trigger("invokePane") },
  hidePane : function(evt){ this.trigger("hidePane") },
});
