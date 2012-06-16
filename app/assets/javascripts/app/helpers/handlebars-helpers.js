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

Handlebars.registerHelper('personImage', function(person, size, imageClass) {
  /* we return here if person.avatar is blank, because this happens when a
   * user is unauthenticated.  we don't know why this happens... */
  if(typeof(person.avatar) == "undefined") { return }

  size = (typeof(size) != "string" ? "small" : size);
  imageClass = (typeof(imageClass) != "string" ? size : imageClass);

  return "<img src=\"" + person.avatar[size] +"\" class=\"avatar " + imageClass + "\" title=\"" + _.escape(person.name) +"\" />";
})
