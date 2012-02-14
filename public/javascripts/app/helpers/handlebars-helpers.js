Handlebars.registerHelper('t', function(scope, values) {
  return Diaspora.I18n.t(scope, values.hash)
})

Handlebars.registerHelper('imageUrl', function(path){
  return app.baseImageUrl() + path;
})