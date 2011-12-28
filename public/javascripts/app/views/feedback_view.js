app.views.Feedback = app.views.StreamObject.extend({
  template_name: "#feedback-template",

  events: {
    "click .like_action": "toggleLike",
    "click .reshare_action": "resharePost"
  },

  initialize : function() {
    var user_like = this.model.get("user_like")
    this.like = user_like && this.model.likes.get(user_like.id);

    _.each(["change", "remove", "add"], function(listener) {
      this.model.likes.bind(listener, this.render, this);
    }, this)
  },

  presenter : function(){
    return _.extend(this.defaultPresenter(), {like : this.like});
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }

    if(this.like){
      this.like.destroy({
        success : function() {
          this.like = null;
        }.apply(this)
      });
    } else {
      this.like = this.model.likes.create();
    }
  },

  resharePost : function(evt){
    if(evt) { evt.preventDefault(); }

    if(window.confirm("Reshare " + this.model.baseAuthor().name + "'s post?")) {
      var reshare = new app.models.Reshare();
      reshare.save({root_guid : this.model.baseGuid()}, {
        success : $.proxy(function(data){
          app.stream.collection.add(this);
        }, reshare)
      });
      return reshare;
    }
  }
})
