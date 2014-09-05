Handlebars.registerHelper('t', function(scope, values) {
  return Diaspora.I18n.t(scope, values.hash)
});

Handlebars.registerHelper('imageUrl', function(path){
  return ImagePaths.get(path);
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
  var avatar = person.avatar || person.profile.avatar;
  if( !avatar ) return;

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
