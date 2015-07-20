// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.collections.Likes = Backbone.Collection.extend({
  model: app.models.Like,

  initialize : function(models, options) {
    this.url = "/posts/" + options.post.id + "/likes"; //not delegating to post.url() because when it is in a stream collection it delegates to that url
  }
});
// @license-end
