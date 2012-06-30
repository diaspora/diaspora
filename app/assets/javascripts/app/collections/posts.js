app.collections.Posts = Backbone.Collection.extend({
  model: app.models.Post,
  url : "/posts"
});

app.collection.PublicPosts = app.collection.Posts.extend({
  url : '/public'
})