app.collections.Likes = Backbone.Collection.extend({
  model: app.models.Like,

  initialize : function(models, options) {
    this.url = "/posts/" + options.post.id + "/likes" //not delegating to post.url() because when it is in a stream collection it delegates to that url
  }
});
