App.Views.Comment = Backbone.View.extend({
  events : {
    "click .delete": "destroyComment"
  },

  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($("#comment-template").html());
  },

  render: function() {
    this.el = $(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )));

    this.delegateEvents(); //we need this because we are explicitly setting this.el in this.render()

    return this;
  },

  // NOTE: pull this out into a base class
  destroyComment: function(evt) {
    if(evt) { evt.preventDefault() }

    var domElement = this.el;

    this.model.destroy({
      success: function(){
        $(domElement).remove();
      }
    });
  }
});
