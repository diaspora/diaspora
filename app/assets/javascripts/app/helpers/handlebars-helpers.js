Handlebars.registerHelper('t', function(scope, values) {
  return Diaspora.I18n.t(scope, values.hash)
});

Handlebars.registerHelper('txtDirClass', function(str) {
  return app.helpers.txtDirection.classFor(str);
});

Handlebars.registerHelper('imageUrl', function(path){
  return ImagePaths.get(path);
});

Handlebars.registerHelper('urlTo', function(path_helper, id, data){
  if( !data ) {
    // only one argument given to helper, mangle parameters
    data = id;
    return Routes[path_helper+'_path'](data.hash);
  }
  return Routes[path_helper+'_path'](id, data.hash);
});

Handlebars.registerHelper('linkToPerson', function(context, block) {
  if( !context ) context = this;
  var html = "<a href=\"/people/" + context.guid + "\" class=\"author-name ";
      html += Handlebars.helpers.hovercardable(context);
      html += "\">";
      html += block.fn(context);
      html += "</a>";

  return html
});

// relationship indicator for profile page
Handlebars.registerHelper('sharingBadge', function(person) {
  var i18n_scope = 'people.helper.is_not_sharing';
  var icon  = 'icons-circle';
  if( person.is_sharing ) {
    i18n_scope = 'people.helper.is_sharing';
    icon = 'icons-check_yes_ok';
  }

  var title = Diaspora.I18n.t(i18n_scope, {name: person.name});
  var html = '<div class="sharing_message_container" title="'+title+'" data-placement="bottom">'+
             '  <div id="sharing_message" class="'+icon+'"></div>'+
             '</div>';
  return html;
});


// allow hovercards for users that are not the current user.
// returns the html class name used to trigger hovercards.
Handlebars.registerHelper('hovercardable', function(person) {
  if( app.currentUser.get('guid') != person.guid ) {
    return 'hovercardable';
  }
  return '';
});

Handlebars.registerHelper('personImage', function(person, size, imageClass) {
  /* we return here if person.avatar is blank, because this happens when a
   * user is unauthenticated.  we don't know why this happens... */
  if( !person.avatar &&
      !(person.profile && person.profile.avatar) ) return;
  var avatar = person.avatar || person.profile.avatar;

  var name = ( person.name ) ? person.name : 'avatar';
  size = ( !_.isString(size) ) ? "small" : size;
  imageClass = ( !_.isString(imageClass) ) ? size : imageClass;

  return _.template('<img src="<%= src %>" class="avatar <%= img_class %>" title="<%= title %>" alt="<%= title %>" />', {
    'src': avatar[size],
    'img_class': imageClass,
    'title': _.escape(name)
  });
});

Handlebars.registerHelper('localTime', function(timestamp) {
  return new Date(timestamp).toLocaleString();
});

Handlebars.registerHelper('fmtTags', function(tags) {
  var links = _.map(tags, function(tag) {
    return '<a class="tag" href="' + Routes.tag_path(tag) + '">' +
           '  #' + tag +
           '</a>';
  }).join(' ');
  return new Handlebars.SafeString(links);
});

Handlebars.registerHelper('fmtText', function(text) {
  return new Handlebars.SafeString(app.helpers.textFormatter(text, null));
});
