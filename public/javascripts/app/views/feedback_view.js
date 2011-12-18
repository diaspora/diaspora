App.Views.Feedback = App.Views.StreamObject.extend({
  template_name: "#feedback-template",

  events: {
    "click .like_action": "toggleLike",
  },

  initialize : function() {
    var user_like = this.model.get("user_like")
    this.like = user_like && this.model.likes.get(user_like.id);

    this.model.likes.bind("change", this.render, this);
    this.model.likes.bind("remove", this.render, this);
    this.model.likes.bind("add", this.render, this);
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
