// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.models.Comment = Backbone.Model.extend({
  urlRoot: "/comments",

  initialize: function() {
    this.likes = new app.collections.Likes(this.get("likes"), {comment: this});
  },

  // Copied from Post.Interaction. To be merged in an "interactable" class once comments can be commented too
  likesCount: function() {
    return this.get("likes_count");
  },

  userLike: function() {
    return this.likes.select(function(like) {
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
    this.userLike().destroy({success: function() {
      self.trigger("change");
      self.set({"likes_count": self.get("likes_count") - 1});
      self.likes.trigger("change");
    }});
  }
});
// @license-end
