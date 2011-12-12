App.Views.Reshare = Backbone.View.extend({
  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($("#reshare-template").html());
  },

  render: function() {
    this.el = $(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )));

    return this;
  }
});
