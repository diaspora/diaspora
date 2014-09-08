
app.views.ProfileSidebar = app.views.Base.extend({
  templateName: 'profile_sidebar',

  initialize: function(opts) {
    this.photos = _.has(opts, 'photos') ? opts.photos : null;
    this.contacts = _.has(opts, 'contacts') ? opts.contacts : null;
  },

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      do_profile_btns: this._shouldDoProfileBtns(),
      do_profile_info: this._shouldDoProfileInfo(),
      do_photos: this._shouldDoPhotos(),
      do_contacts: this._shouldDoContacts(),
      is_sharing: this.model.isSharing(),
      is_receiving: this.model.isReceiving(),
      is_mutual: this.model.isMutual(),
      is_not_blocked: !this.model.isBlocked(),
      photos: this.photos,
      contacts: this.contacts
    });
  },

  _shouldDoProfileBtns: function() {
    return (app.currentUser.authenticated() && !this.model.get('is_own_profile'));
  },

  _shouldDoProfileInfo: function() {
    return (this.model.isSharing() || this.model.get('is_own_profile'));
  },

  _shouldDoPhotos: function() {
    return (this.photos && this.photos.items.length > 0);
  },

  _shouldDoContacts: function() {
    return (this.contacts && this.contacts.items.length > 0);
  },

  postRenderTemplate: function() {
    // UGLY (re-)attach the facebox
    this.$('a[rel*=facebox]').facebox();
  }
});
