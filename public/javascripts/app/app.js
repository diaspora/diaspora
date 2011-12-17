var App = {
  Collections: {},
  Models: {},
  Views: {},

  user: function(user) {
    if(user) { return this._user = user; }

    return this._user;
  },

  initialize: function() {
    App.router = new App.Router;

    if(this._user){
      App.header = new App.Views.Header;
      $("body").prepend(App.header.el);
      App.header.render();
    }

    Backbone.history.start({pushState: true});
  }
};

$(function() { App.initialize(); });
