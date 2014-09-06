
app.views.ProfileStream = app.views.Base.extend({
  templateName: 'profile_stream',

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      is_blocked: this.model.isBlocked()
    });
  }
});
