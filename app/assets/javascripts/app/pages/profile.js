
app.pages.Profile = app.views.Base.extend({
  events: {
    'click #block_user_button': 'blockPerson',
    'click #unblock_user_button': 'unblockPerson'
  },

  subviews: {
    '#profile': 'sidebarView',
    '.profile_header': 'headerView',
    '#main_stream': 'streamView'
  },

  tooltipSelector: '.profile_button div, .sharing_message_container',

  initialize: function(opts) {
    if( app.hasPreload('person') )
      this.model = new app.models.Person(app.parsePreload('person'));
    if( app.hasPreload('photos') )
      this.photos = app.parsePreload('photos');  // we don't interact with it, so no model
    if( app.hasPreload('contacts') )
      this.contacts = app.parsePreload('contacts');  // we don't interact with it, so no model

    this.model.on('change', this.render, this);

    // bind to global events
    var id = this.model.get('id');
    app.events.on('person:block:'+id, this.reload, this);
    app.events.on('person:unblock:'+id, this.reload, this);
    app.events.on('aspect_membership:update', this.reload, this);
  },

  sidebarView: function() {
    return new app.views.ProfileSidebar({
      model: this.model,
      photos: this.photos,
      contacts: this.contacts
    });
  },

  headerView: function() {
    return new app.views.ProfileHeader({model: this.model});
  },

  streamView: function() {
    if( this.model.isBlocked() ) {
      $('#main_stream').empty().html(
        '<div class="dull">'+
        Diaspora.I18n.t('profile.ignoring', {name: this.model.get('name')}) +
        '</div>');
      return false;
    }

    app.stream = new app.models.Stream(null, {basePath: Routes.person_stream_path(app.page.model.get('guid'))});
    app.stream.fetch();
    return new app.views.Stream({model: app.stream});
  },

  blockPerson: function(evt) {
    if( !confirm(Diaspora.I18n.t('ignore_user')) ) return;

    var block = this.model.block();
    block.fail(function() {
      Diaspora.page.flashMessages.render({
        success: false,
        notice: Diaspora.I18n.t('ignore_failed')
      });
    });

    return false;
  },

  unblockPerson: function(evt) {
    var block = this.model.unblock();
    block.fail(function() {
      Diaspora.page.flashMessages.render({
        success: false,
        notice: Diaspora.I18.t('unblock_failed')
      });
    });
    return false;
  },

  reload: function() {
    this.model.fetch();
  }
});
