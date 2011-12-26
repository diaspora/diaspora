App.Router = Backbone.Router.extend({
  routes: {
    "stream": "stream",
    "comment_stream": "stream",
    "like_stream": "stream",
    "mentions": "stream",
    "people/:id": "stream",
      "u/:name": "stream",
    "tag_followings": "stream",
    "tags/:name": "stream",
    "posts/:id": "stream"
  },

  stream: function() {
    App.stream = new App.Views.Stream().render();
    $("#main_stream").html(App.stream.el);
  }
});
