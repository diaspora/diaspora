//= require ./stream_object_view
app.views.LikesInfo = app.views.StreamObject.extend({

  templateName : "likes-info",

  events : {
    "click .expand_likes" : "showAvatars"
  },

  tooltipSelector : ".avatar",

  initialize : function() {
    this.model.bind('expandedLikes', this.render, this)
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      likes : this.model.likes.models
    })
  },

  showAvatars : function(evt){
    if(evt) { evt.preventDefault() }
    var self = this;
    this.model.likes.fetch()
      .done(function(resp){
      // set like attribute and like collection
      self.model.set({likes : self.model.likes.reset(resp)})
      self.model.trigger("expandedLikes")
    })
  }
});
