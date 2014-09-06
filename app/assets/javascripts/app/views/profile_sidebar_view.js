
app.views.ProfileSidebar = app.views.Base.extend({
  templateName: 'profile_sidebar',

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      do_profile_btns: this._shouldDoProfileBtns(),
      is_sharing: this.model.isSharing(),
      is_receiving: this.model.isReceiving(),
      is_mutual: this.model.isMutual(),
      is_not_blocked: !this.model.isBlocked()
    });
  },

  _shouldDoProfileBtns: function() {
    return (app.currentUser.authenticated() && !this.model.get('is_own_profile'));
  },

  postRenderTemplate: function() {
    // UGLY (re-)attach the facebox
    this.$('a[rel*=facebox]').facebox();
  }
});
