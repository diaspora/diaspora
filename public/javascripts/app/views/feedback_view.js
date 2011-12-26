app.views.Feedback = app.views.StreamObject.extend({
  template_name: "#feedback-template",

  events: {
    "click .like_action": "toggleLike",
  },

  initialize : function() {
    var user_like = this.model.get("user_like")
    this.like = user_like && this.model.likes.get(user_like.id);

    _.each(["change", "remove", "add"], function(listener) {
      this.model.likes.bind(listener, this.render, this);
    }, this)
  },

  presenter : function(){
    return _.extend(this.defaultPresenter, {like : this.like});
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }

    if(this.like){
      this.like.destroy();
    } else {
      this.like = this.model.likes.create();
    }
  },
})
