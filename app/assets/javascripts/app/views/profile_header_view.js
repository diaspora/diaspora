
app.views.ProfileHeader = app.views.Base.extend({
  templateName: 'profile_header',

  initialize: function() {
    app.events.on('aspect:create', this.postRenderTemplate, this);
  },

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
    if( dropdownEl.length == 0 ) {
      this._done();
      return;
    }

    // TODO render me client side!!!
    var href = this.model.url() + '/aspect_membership_button?create=true';
    if( gon.bootstrap ) href += '&bootstrap=true';

    $.get(href, function(resp) {
      dropdownEl.html(resp);
      new app.views.AspectMembership({el: dropdownEl});

      // UGLY (re-)attach the facebox
      self.$('a[rel*=facebox]').facebox();
      this._done();
    });
  },

  _done: function() {
    app.page.asyncSubHeader && app.page.asyncSubHeader.resovle();
  }
});
