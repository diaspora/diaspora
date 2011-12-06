App.Routers.Stream = Backbone.Router.extend({
  routes: {
    "stream": "stream"
  },

  stream: function() {
    App.stream = new App.Views.Stream;
  }
});
