app.collections.Posts = Backbone.Collection.extend({
  model: app.models.Post,
  url : "/posts"
});
