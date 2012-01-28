var app = {
  collections: {},
  models: {},
  helpers: {},
  views: {},

  user: function(user) {
    if(user) { return this._user = user }
    return this._user || false
  },

  baseImageUrl: function(baseUrl){
    if(baseUrl) { return this._baseImageUrl = baseUrl }
    return this._baseImageUrl || ""
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

$(function() { 
  Handlebars.registerHelper('t', function(scope, values) {
    return Diaspora.I18n.t(scope, values.hash)
  })

  Handlebars.registerHelper('imageUrl', function(path){
    return app.baseImageUrl() + path;
  })

  app.initialize();
});
