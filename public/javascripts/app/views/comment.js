App.Views.Comment = Backbone.View.extend({
  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($("#comment-template").html());
  },

  render: function() {
    this.el = $(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )));

    return this.el;
  }
});
