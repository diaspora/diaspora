// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
Handlebars.registerHelper('sharingMessage', function(person) {
  var i18n_scope = 'people.helper.is_not_sharing';
  var icon = "circle";
  if( person.is_sharing ) {
    i18n_scope = 'people.helper.is_sharing';
    icon = "entypo check";
  }

  var title = Diaspora.I18n.t(i18n_scope, {name: person.name});
  var html = '<span class="sharing_message_container" title="'+title+'" data-placement="bottom">'+
             '  <i id="sharing_message" class="'+icon+'"></i>'+
             '</span>';
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

  return _.template('<img src="<%= src %>" class="avatar <%= img_class %>" title="<%= title %>" alt="<%= title %>" />')({
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

Handlebars.registerHelper('isCurrentPage', function(path_helper, id, options){
  var currentPage = "/"+Backbone.history.fragment;
  if (currentPage == Handlebars.helpers.urlTo(path_helper, id, options.data)) {
    return options.fn(this);
  } else {
    return options.inverse(this);
  }
});

Handlebars.registerHelper('isCurrentProfilePage', function(id, diaspora_handle, options){
  var username = diaspora_handle.split("@")[0];
  return Handlebars.helpers.isCurrentPage('person', id, options) ||
         Handlebars.helpers.isCurrentPage('user_profile', username, options);
});
// @license-end

