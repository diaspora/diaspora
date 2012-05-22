app.views.Post.StreamFrame = app.views.Base.extend({
  className : "stream-frame",

  templateName : "stream-frame",

  subviews : {
    ".small-frame" : "smallFrameView"
  },

  initialize : function(options) {
    this.stream = options.stream
    this.smallFrameView = new app.views.Post.SmallFrame({model : this.model, stream: this.stream})
  },

  events : _.extend({
    'click .content' : 'triggerInteracted'
  }, app.views.Post.SmallFrame.prototype.events),


  triggerInteracted : function() {
    this.stream.trigger("frame:interacted", this.model)
  },

  goToPost : $.noop
});
