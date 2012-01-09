var app = {
  collections: {},
  models: {},
  views: {},

  user: function(user) {
    if(user) { return this._user = user; }

    return this._user || {current_user : false};
  },

  initialize: function() {
    app.router = new app.Router();

    if(this._user){
      app.header = new app.views.Header;
      $("body").prepend(app.header.el);
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

$(function() { app.initialize(); });
