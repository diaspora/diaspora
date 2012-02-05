app.views.LikesInfo = app.views.StreamObject.extend({

  templateName : "likes-info",

  className : "likes_container",

  events : {
    "click .expand_likes" : "showAvatars"
  },

  tooltipSelector : ".avatar",

  presenter : function() {
    return _.extend(this.defaultPresenter(), {likes : this.model.likes.models})
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
