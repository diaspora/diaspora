App.Views.CommentStream = Backbone.View.extend({
  events: {
    "submit form": "createComment"
  },

  initialize: function(options) {
    this.model = options.model;
    this.template = _.template($("#comment-stream-template").html());

    _.bindAll(this, "appendComment");
    this.model.comments.bind("add", this.appendComment);
  },

  render: function() {
    var self = this;

    $(this.el).html(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )));

    this.model.comments.each(this.appendComment);

    return this.el;
  },

  createComment: function(evt) {
    evt.preventDefault();

    this.model.comments.create({
      "text" : this.$(".comment_box").val(),
      "post_id" : this.model.id
    });

    this.$(".comment_box").val("");
    return this;
  },

  appendComment: function(comment) {
    this.$("ul.comments").append(new App.Views.Comment({
      model: comment
    }).render());
  }

});
