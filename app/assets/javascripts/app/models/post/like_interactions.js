// This class contains code extracted from interactions.js to factorize likes management between posts and comments

app.models.Post.LikeInteractions = Backbone.Model.extend({

  initialize: function(options) {
    this.likes = new app.collections.Likes(this.get("likes"), options);
  },

  likesCount: function() {
    return this.get("likes_count");
  },

  userLike: function() {
    return this.likes.select(function(like){
      return like.get("author") && like.get("author").guid === app.currentUser.get("guid");
    })[0];
  },

  toggleLike: function() {
    if (this.userLike()) {
      this.unlike();
    } else {
      this.like();
    }
  },

  like: function() {
    var self = this;
    this.likes.create({}, {
      success: function() {
        self.post.set({participation: true});
        self.trigger("change");
        self.set({"likes_count": self.get("likes_count") + 1});
        self.likes.trigger("change");
      },
      error: function(model, response) {
        app.flashMessages.handleAjaxError(response);
      }
    });
  },

  unlike: function() {
    var self = this;
    this.userLike().destroy({
      success: function() {
        self.post.set({participation: false});
        self.trigger("change");
        self.set({"likes_count": self.get("likes_count") - 1});
        self.likes.trigger("change");
      },
      error: function(model, response) {
        app.flashMessages.handleAjaxError(response);
      }});
  }
});
