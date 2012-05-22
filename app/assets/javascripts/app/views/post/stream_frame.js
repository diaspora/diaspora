app.views.Post.StreamFrame = app.views.Base.extend({

  className : "stream-frame",

  templateName : "stream-frame",

  subviews : {
    ".small-frame" : "smallFrameView"
  },

  initialize : function() {
    this.smallFrameView = new app.views.Post.SmallFrame({model : this.model})
  },

  events : _.extend({
    'click .content' : 'triggerInteracted'
  }, app.views.Post.SmallFrame.prototype.events),

  triggerInteracted : function() {
    app.page.trigger("frame:interacted", this.model)
  },

  // this is some gross shit.
  goToPost : $.noop
});