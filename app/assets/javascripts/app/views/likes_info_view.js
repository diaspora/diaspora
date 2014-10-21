// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
// @license-end

