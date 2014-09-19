
app.views.ProfileSidebar = app.views.Base.extend({
  templateName: 'profile_sidebar',

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      show_profile_info: this._shouldShowProfileInfo(),
    });
  },

  _shouldShowProfileInfo: function() {
    return (this.model.isSharing() || this.model.get('is_own_profile'));
  }
});
