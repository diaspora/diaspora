// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.ProfileHeader = app.views.Base.extend({
  templateName: 'profile_header',

  initialize: function(opts) {
    app.events.on('aspect:create', this.postRenderTemplate, this);
    this.photos = _.has(opts, 'photos') ? opts.photos : null;
    this.contacts = _.has(opts, 'contacts') ? opts.contacts : null;
  },

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      show_profile_btns: this._shouldShowProfileBtns(),
      show_photos: this._shouldShowPhotos(),
      show_contacts: this._shouldShowContacts(),
      is_blocked: this.model.isBlocked(),
      is_sharing: this.model.isSharing(),
      is_receiving: this.model.isReceiving(),
      is_mutual: this.model.isMutual(),
      has_tags: this._hasTags(),
      contacts: this.contacts,
      photos: this.photos
    });
  },

  _hasTags: function() {
    return (this.model.get('profile')['tags'].length > 0);
  },

  _shouldShowProfileBtns: function() {
    return (app.currentUser.authenticated() && !this.model.get('is_own_profile'));
  },

  _shouldShowPhotos: function() {
    return (this.photos && this.photos.count > 0);
  },

  _shouldShowContacts: function() {
    return (this.contacts && this.contacts.count > 0);
  },

  postRenderTemplate: function() {
    var self = this;
    var dropdownEl = this.$('.aspect_membership_dropdown.placeholder');
    if( dropdownEl.length == 0 ) {
      this._done();
      return;
    }

    // TODO render me client side!!!
    var href = this.model.url() + '/aspect_membership_button?create=true&size=normal';
    if( gon.bootstrap ) href += '&bootstrap=true';

    $.get(href, function(resp) {
      dropdownEl.html(resp);
      new app.views.AspectMembership({el: $('.aspect_dropdown',dropdownEl)});

      // UGLY (re-)attach the facebox
      self.$('a[rel*=facebox]').facebox();
      self._done();
    });
  },

  _done: function() {
    app.page.asyncSubHeader && app.page.asyncSubHeader.resovle();
  }
});
// @license-end

