var App = {
  Collections: {},
  Models: {},
  routers: {},
  Routers: {},
  Views: {},

  user: function(user) {
    if(user) { return this._user = user; }

    return this._user;
  },

  initialize: function() {
    _.each(App.Routers, function(Router, name) {
      App.routers[name] = new Router;
    });

    Backbone.history.start({pushState: true});
  }
};

$(function() { App.initialize(); });
