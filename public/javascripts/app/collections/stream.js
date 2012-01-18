app.collections.Stream = Backbone.Collection.extend({
  url: function() {
    var path = document.location.pathname;

    if(this.models.length) {
      path += "?max_time=" + _.last(this.models).createdAt();
    }

    return path;
  },

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
