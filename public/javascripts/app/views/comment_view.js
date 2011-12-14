App.Views.Comment = App.Views.StreamObject.extend({

  template_name: "#comment-template",

  events : {
    "click .delete:first": "destroyModel"
  },

  render: function() {
    this.el = $(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )));

    this.delegateEvents(); //we need this because we are explicitly setting this.el in this.render()

    return this;
  }
});
