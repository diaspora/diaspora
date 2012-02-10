app.views.LikesInfo = app.views.StreamObject.extend({

  templateName : "likes-info",

  events : {
    "click .expand_likes" : "showAvatars"
  },

  tooltipSelector : ".avatar",

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      likes : this.model.likes.models,
      hasLikes : this.hasLikes()
    })
  },

  hasLikes : function() {
    return this.model.likes.models.length > 0
  },

  showAvatars : function(evt){
    if(evt) { evt.preventDefault() }
    var self = this;
    this.model.likes.fetch()
      .done(function(resp){
      // set like attribute and like collection
      self.model.set({likes : self.model.likes.reset(resp)})
    })
  }
});
