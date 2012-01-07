var app = {
  collections: {},
  models: {},
  views: {},

  user: function(user) {
    if(user) { return this._user = user; }

    return this._user || {current_user : false};
  },

  initialize: function() {
    app.router = new app.Router;

    if(this._user){
      app.header = new app.views.Header;
      $("body").prepend(app.header.el);
      app.header.render();
    }

    Backbone.history.start({pushState: true});
  }
};

$(function() { app.initialize(); });
