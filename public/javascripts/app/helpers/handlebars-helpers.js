Handlebars.registerHelper('t', function(scope, values) {
  return Diaspora.I18n.t(scope, values.hash)
})

Handlebars.registerHelper('imageUrl', function(path){
  return app.baseImageUrl() + path;
})

Handlebars.registerHelper('linkToPerson', function(context, block) {
  var html = "<a href=\"/people/" + context.guid + "\" class=\"author-name\">";
      html+= block.fn(context);
      html+= "</a>";

  return html
})

Handlebars.registerHelper('avatar', function(person, size, imageClass) {
  size = (typeof(size) != "string" ? "small" : size);
  imageClass = (typeof(imageClass) != "string" ? size : imageClass);

  return "<img src=\"" + person.avatar[size] +"\" class=\"avatar " + imageClass + "\" title=\"" + person.name +"\" />";
})
