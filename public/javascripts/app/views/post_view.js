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

    this.renderPostContent();

    this.$(".details time").timeago();
    this.$("label").inFieldLabels();

    return this;
  },

  renderPostContent: function(){
    var normalizedClass = this.model.get("post_type").replace(/::/, "__");
    var postClass = App.Views[normalizedClass] || App.Views.StatusMessage;
    var postView = new postClass({ model : this.model });

    this.$(".post-content").html(postView.render().el);

    return this;
  }
});
