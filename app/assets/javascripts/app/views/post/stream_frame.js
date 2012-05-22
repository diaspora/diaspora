app.views.Post.StreamFrame = app.views.Post.SmallFrame.extend({
  events : _.extend({
    'click .content' : 'triggerInteracted'
  }, app.views.Post.SmallFrame.prototype.events),

  triggerInteracted : function() {
    app.page.trigger("frame:interacted", this.model)
  }
})