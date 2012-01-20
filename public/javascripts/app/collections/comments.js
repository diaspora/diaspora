app.collections.Comments = Backbone.Collection.extend({
  model: app.models.Comment,

  initialize : function(models, options) {
    this.url = "/posts/" + options.post.id + "/comments" //not delegating to post.url() because when it is in a stream collection it delegates to that url
  }
});
