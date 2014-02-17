app.views.LikesInfo = app.views.Base.extend({

  templateName : "likes-info",

  events : {
    "click .expand_likes" : "showAvatars"
  },

  tooltipSelector : ".avatar",

  initialize : function() {
    this.model.interactions.bind('change', this.render, this);
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      likes : this.model.interactions.likes.toJSON(),
      likesCount : this.model.interactions.likesCount(),
      likes_fetched : this.model.interactions.get("fetched"),
    })
  },

  showAvatars : function(evt){
    if(evt) { evt.preventDefault() }
    this.model.interactions.fetch()
  }
});
