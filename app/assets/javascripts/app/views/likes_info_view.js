// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.LikesInfo = app.views.Base.extend({

  templateName : "likes-info",

  events : {
    "click .expand-likes" : "showAvatars"
  },

  tooltipSelector : ".avatar",

  initialize : function() {
    this.model.interactions.likes.on("change", this.render, this);
    this.displayAvatars = false;
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      likes : this.model.interactions.likes.toJSON(),
      likesCount : this.model.interactions.likesCount(),
      displayAvatars: this.displayAvatars
    });
  },

  showAvatars : function(evt){
    if(evt) { evt.preventDefault() }
    this.displayAvatars = true;
    this.model.interactions.likes.fetch({success: function() {
      this.model.interactions.likes.trigger("change");
    }.bind(this)});
  }
});
// @license-end
