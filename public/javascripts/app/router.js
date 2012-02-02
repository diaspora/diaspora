app.Router = Backbone.Router.extend({
  routes: {
    "participate": "stream",
    "stream": "stream",
    "aspects:query": "stream",
    "commented": "stream",
    "liked": "stream",
    "mentions": "stream",
    "people/:id": "stream",
      "u/:name": "stream",
    "followed_tags": "stream",
    "tags/:name": "stream",
    "posts/:id": "stream",
    "p/:id": "stream"
  },

  stream : function() {
    app.stream = new app.models.Stream()
    app.page = new app.views.Stream({model : app.stream}).render();
    app.publisher = app.publisher || new app.views.Publisher({collection : app.stream.posts});

    var streamFacesView = new app.views.StreamFaces({collection : app.stream.posts}).render();

    $("#main_stream").html(app.page.el);
    $('#selected_aspect_contacts .content').html(streamFacesView.el);
  }
});

