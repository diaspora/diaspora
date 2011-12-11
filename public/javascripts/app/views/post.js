App.Views.Post = Backbone.View.extend({

  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($("#stream-element-template").html());
  },

  render: function() {
    var self = this;
    this.el = $(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )))[0];

    this.$(".comments").html(new App.Views.CommentStream({
      model: this.model
    }).render());

    this.$(".details time").timeago();
    this.$("label").inFieldLabels();

    Diaspora.BaseWidget.instantiate("StreamElement", $(this.el));

    return this.el;
  }
});
