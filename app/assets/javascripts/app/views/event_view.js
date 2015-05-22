app.views.Event = app.views.Base.extend({
  templateName: "event",

  initialize: function() {
    this.model.on("change", this.render, this);
  },

  presenter: function() {
    var defaultPresenter = this.defaultPresenter();

    return _.extend(defaultPresenter, {
    });
  }
});
