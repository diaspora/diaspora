app.views.Message = app.views.Base.extend({
  templateName: 'message',

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      text: app.helpers.textFormatter(this.model.get('text'), this.model)
    });
  }
});
