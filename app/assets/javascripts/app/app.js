//= require_self
//= require_tree ./helpers
//= require ./router
//= require ./models
//= require ./views
//= require_tree ./models
//= require_tree ./pages
//= require_tree ./collections
//= require_tree ./views
//= require_tree ./forms

var app = {
  collections: {},
  models: {},
  helpers: {},
  views: {},
  pages: {},
  forms: {},

  user: function(userAttrs) {
    if(userAttrs) { return this._user = new app.models.User(userAttrs) }
    return this._user || false
  },

  baseImageUrl: function(baseUrl){
    if(baseUrl) { return this._baseImageUrl = baseUrl }
    return this._baseImageUrl || "assets/"
  },

  initialize: function() {
    app.router = new app.Router();

    app.currentUser = app.user(window.current_user_attributes) || new app.models.User()

    if(app.currentUser.authenticated()){
      app.header = new app.views.Header;
      $("header").prepend(app.header.el);
      app.header.render();
    }


    Backbone.history.start({pushState: true});

    // there's probably a better way to do this...
    $("a[rel=backbone]").bind("click", function(evt){
      evt.preventDefault();
      var link = $(this);

      $(".stream_title").text(link.text())
      app.router.navigate(link.attr("href").substring(1) ,true)
    })
  }
};

$(function() {
  app.initialize();
});
