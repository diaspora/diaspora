// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.collections.Likes = Backbone.Collection.extend({
  model: app.models.Like,

  initialize : function(models, options) {
    // A comment- like has a post reference and a comment reference
    this.url = (options.comment != null) ?
      // not delegating to post.url() because when it is in a stream collection it delegates to that url
      "/comments/" + options.comment.id + "/likes" :
      "/posts/" + options.post.id + "/likes";
  }
});
// @license-end
