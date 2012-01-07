app.collections.Stream = Backbone.Collection.extend({
  url: function() {
    var path = document.location.pathname;

    if(this.models.length) {
      path += "?max_time=" + _.last(this.models).createdAt();
    }

    return path;
  },

  model: app.models.Post,

  parse: function(resp){
    return resp.posts;
  },

  comparator : function(post) {
    return -post.createdAt();
  }
});
