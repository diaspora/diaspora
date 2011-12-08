App.Views.Post = Backbone.View.extend({
  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($("#stream-element-template").html());
  },

  render: function() {
    this.el = $(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )));

    this.$("ul.comments").html(new App.Views.CommentStream({
      collection: this.model.comments
    }).render());

    this.$(".details time").timeago();
    this.$("label").inFieldLabels();
    
    return this.el;
  }
});
