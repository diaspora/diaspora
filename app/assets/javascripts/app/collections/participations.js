app.collections.Participations = Backbone.Collection.extend({
  model: app.models.Participation,

  initialize : function(models, options) {
    this.url = "/posts/" + options.post.id + "/participations" //not delegating to post.url() because when it is in a stream collection it delegates to that url
  }
});
