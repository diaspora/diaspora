
app.views.ProfileHeader = app.views.Base.extend({
  templateName: 'profile_header',

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      is_blocked: this.model.isBlocked(),
      has_tags: this._hasTags()
    });
  },

  _hasTags: function() {
    return (this.model.get('profile')['tags'].length > 0);
  },

  postRenderTemplate: function() {
    var self = this;
    var dropdownEl = this.$('.aspect_membership_dropdown.placeholder');
    if( dropdownEl.length == 0 ) return;

    // TODO render me client side!!!
    var href = this.model.url() + '/aspect_membership_button?create=true';
    if( gon.bootstrap ) href += '&bootstrap=true';

    $.get(href, function(resp) {
      dropdownEl.html(resp);
      new app.views.AspectMembership({el: dropdownEl});
    })
  }
});
