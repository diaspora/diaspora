app.Router = Backbone.Router.extend({
  routes: {
    "activity": "stream",
    "stream": "stream",

    "participate": "stream",
    "explore": "stream",

    "aspects:query": "stream",
    "commented": "stream",
    "liked": "stream",
    "mentions": "stream",
    "people/:id": "stream",
    "people/:id/photos": "photos",
    "u/:name": "stream",
    "followed_tags": "stream",
    "tags/:name": "stream",

    "posts/new" : "newPost",
    "posts/:id": "singlePost",
    "p/:id": "singlePost"
  },

  stream : function() {
    app.stream = new app.models.Stream();
    app.page = new app.views.Stream({model : app.stream}).render();
    app.publisher = app.publisher || new app.views.Publisher({collection : app.stream.posts});

    var streamFacesView = new app.views.StreamFaces({collection : app.stream.posts}).render();

    $("#main_stream").html(app.page.el);
    $('#selected_aspect_contacts .content').html(streamFacesView.el);
  },

  photos : function() {
    app.photos = new app.models.Photos();
    app.page = new app.views.Photos({model : app.photos}).render();

    $("#main_stream").html(app.page.el);
  },

  newPost : function(){
    var page = new app.pages.PostNew();
    $("#container").html(page.render().el)
  },

  singlePost : function(id) {
    var page = new app.pages.PostViewer({ id: id });
    $("#container").html(page.el);
   }
});

