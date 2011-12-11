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

    Backbone.history.start({pushState: true});
  }
};

$(function() { App.initialize(); });
