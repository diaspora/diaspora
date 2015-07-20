// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
// @license-end

