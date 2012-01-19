app.Router = Backbone.Router.extend({
  routes: {
    "stream": "stream",
    "aspects:query": "stream",
    "commented": "stream",
    "liked": "stream",
    "mentions": "stream",
    "people/:id": "stream",
      "u/:name": "stream",
    "followed_tags": "stream",
    "tags/:name": "stream",
    "posts/:id": "stream"
  },

  stream : function() {
    app.stream = new app.views.Stream().render();
    $("#main_stream").html(app.stream.el);

    var streamFacesView = new app.views.StreamFaces({collection : app.stream.collection}).render();
    $('#selected_aspect_contacts .content').html(streamFacesView.el);
  }
});

