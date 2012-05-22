app.views.Post.StreamFrame = app.views.Post.SmallFrame.extend({
  events :_.extend({
    'click .content' : 'fetchInteractions'
  }, app.views.Post.SmallFrame.prototype.events),

  subviews :_.extend({
    '.interactions' : 'interactionsView'
  }, app.views.Post.SmallFrame.prototype.subviews),

  initialize : function(){
    this.interactionsView = new app.views.StreamInteractions({model : this.model})
  },

  postRenderTemplate : function(){
    this.addStylingClasses()
    this.$el.append($("<div class='interactions'/>"))
  },

  fetchInteractions : function() {
    this.model.interactions.fetch().done(_.bind(function(){
      this.interactionsView.render()
    }, this));
  }
})