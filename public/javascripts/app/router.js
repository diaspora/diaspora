App.Router = Backbone.Router.extend({
  routes: {
    "stream": "stream",
    "comment_stream": "stream",
    "like_stream": "stream",
    "mentions": "stream",
    "people/:id": "stream",
    "tag_followings": "stream",
    "tags/:name": "stream"
  },

  stream: function() {
    App.stream = new App.Views.Stream;
    $("#main_stream").html(App.stream.el);

    App.stream.loadMore();
  }
});
