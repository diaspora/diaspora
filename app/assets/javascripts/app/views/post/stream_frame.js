app.views.Post.StreamFrame = app.views.Base.extend({
  className : "stream-frame",

  templateName : "stream-frame",

  subviews : {
    ".small-frame" : "smallFrameView",
    ".stream-frame-feedback" : "feedbackView"
  },

  initialize : function(options) {
    this.stream = options.stream
    this.smallFrameView = new app.views.Post.SmallFrame({model : this.model})
    this.feedbackView =  new app.views.FeedbackActions({ model: this.model })
  },

  events : {
    'click .content' : 'triggerInteracted',
    "click a.permalink" : "goToPost"
  },

  triggerInteracted : function() {
    this.stream.trigger("frame:interacted", this.model)
  },

  goToPost : function(evt) {
    this.smallFrameView.goToPost(evt)
  }
});
