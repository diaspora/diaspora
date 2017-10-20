// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

Handlebars.registerHelper('t', function(scope, values) {
  return Diaspora.I18n.t(scope, values.hash);
});

Handlebars.registerHelper('txtDirClass', function(str) {
  return app.helpers.txtDirection.classFor(str);
});

Handlebars.registerHelper('imageUrl', function(path){
  return ImagePaths.get(path);
});

Handlebars.registerHelper("urlTo", function(pathHelper, id, data){
  if( !data ) {
    // only one argument given to helper, mangle parameters
    data = id;
    return Routes[pathHelper](data.hash);
  }
  return Routes[pathHelper](id, data.hash);
});

Handlebars.registerHelper('linkToAuthor', function(context, block) {
  if( !context ) context = this;
  var html = "<a href=\"/people/" + context.guid + "\" class=\"author-name ";
      html += Handlebars.helpers.hovercardable(context);
      html += "\">";
      html += block.fn(context);
      html += "</a>";

  return html;
});

Handlebars.registerHelper('linkToPerson', function(context, block) {
  if( !context ) context = this;
  var html = "<a href=\"/people/" + context.guid + "\" class=\"name\">";
      html += block.fn(context);
      html += "</a>";

  return html;
});

// relationship indicator for profile page
Handlebars.registerHelper("sharingMessage", function(person) {
  var i18nScope = "people.helper.is_not_sharing";
  var icon = "circle";
  if( person.is_sharing ) {
    i18nScope = "people.helper.is_sharing";
    icon = "entypo-check";
  }

  var title = Diaspora.I18n.t(i18nScope, {name: _.escape(person.name)});
  var html = '<span class="sharing_message_container" title="'+title+'" data-placement="bottom">'+
             '  <i id="sharing_message" class="'+icon+'"></i>'+
             '</span>';
  return html;
});


// allow hovercards for users that are not the current user.
// returns the html class name used to trigger hovercards.
Handlebars.registerHelper("hovercardable", function(person) {
  return app.currentUser.get("guid") === person.guid ? "" : "hovercardable";
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

  return _.template("<img src=\"<%= src %>\" class=\"<%= imageClass %>\" " +
      "title=\"<%= title %>\" alt=\"<%= title %>\" />")({
    src: avatar[size],
    imageClass: imageClass + " avatar img-responsive center-block",
    title: _.escape(name)
  });
});

Handlebars.registerHelper('localTime', function(timestamp) {
  return new Date(timestamp).toLocaleString();
});

Handlebars.registerHelper("fmtTags", function(tags) {
  var links = _.map(tags, function(tag) {
    return "<a class=\"tag\" href=\"" + Routes.tag(tag) + "\">" +
           "  #" + tag +
           "</a>";
  }).join(" ");
  return new Handlebars.SafeString(links);
});

Handlebars.registerHelper("fmtText", function(text) {
  return new Handlebars.SafeString(app.helpers.textFormatter(text));
});

Handlebars.registerHelper("isCurrentPage", function(pathHelper, id, options){
  var currentPage = "/"+Backbone.history.fragment;
  if (currentPage === Handlebars.helpers.urlTo(pathHelper, id, options.data)) {
    return options.fn(this);
  } else {
    return options.inverse(this);
  }
});

Handlebars.registerHelper("isCurrentProfilePage", function(id, diasporaHandle, options){
  var username = diasporaHandle.split("@")[0];
  return Handlebars.helpers.isCurrentPage("person", id, options) ||
         Handlebars.helpers.isCurrentPage("userProfile", username, options);
});

Handlebars.registerHelper('aspectMembershipIndicator', function(contact,in_aspect) {
  if(!app.aspect || !app.aspect.get('id')) return '<div class="aspect-membership-dropdown placeholder"></div>';

  var html = "<i class=\"entypo-";
  if( in_aspect === 'in_aspect' ) {
    html += 'circled-cross contact_remove-from-aspect" ';
    html += 'title="' + Diaspora.I18n.t('contacts.remove_contact') + '" ';
  } else {
    html += 'circled-plus contact_add-to-aspect" ';
    html += 'title="' + Diaspora.I18n.t('contacts.add_contact') + '" ';
  }
  html += '></i>';
  return html;
});
// @license-end
