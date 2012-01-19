app.collections.Posts = Backbone.Collection.extend({
  url : "/posts",

  model: function(attrs, options) {
    var modelClass = app.models[attrs.post_type] || app.models.Post
    return new modelClass(attrs, options);
  },

  parse: function(resp){
    return resp.posts;
  },

  comparator : function(post) {
    return -post.createdAt();
  }
});
