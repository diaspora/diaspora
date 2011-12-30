app.views.Feedback = app.views.StreamObject.extend({
  template_name: "#feedback-template",

  events: {
    "click .like_action": "toggleLike",
    "click .reshare_action": "resharePost"
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }

    var userLike = this.model.get("user_like");

    if(userLike) {
      this.model.likes.get(userLike.id).destroy({
        success : $.proxy(function() {
          this.model.set({user_like : null, likes_count : this.model.get("likes_count") - 1});
        }, this)
      });
    } else {
      this.model.likes.create({}, {
        success : $.proxy(function(like) {
          this.model.set({user_like : like, likes_count : this.model.get("likes_count") + 1}); // this should be in a callback...
        }, this)
      });
    }
  },

  resharePost : function(evt){
    if(evt) { evt.preventDefault(); }

    if(window.confirm("Reshare " + this.model.baseAuthor().name + "'s post?")) {
      var reshare = new app.models.Reshare();
      reshare.save({root_guid : this.model.baseGuid()}, {
        success : function(data){
          var newPost = new app.models.Post(data);
          app.stream.collection.add(newPost, {silent : true});
          app.stream.prependPost(newPost);
        }
      });
      return reshare;
    }
  }
})
