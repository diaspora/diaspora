// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.collections.Comments = Backbone.Collection.extend({
  model: app.models.Comment,
  url: function() {
      return _.result(this.post, "url") + "/comments";
  },

  initialize : function(models, options) {
    this.post = options.post;
  },

  make : function(text) {
    var self = this;
    var comment = new app.models.Comment({ "text": text });

    var deferred = comment.save({}, {
      url: "/posts/"+ this.post.id +"/comments",
      success: function() {
        comment.set({author: app.currentUser.toJSON(), parent: self.post });
        self.add(comment);
      }
    });

    return deferred;
  }
});
// @license-end
