App.Views.Post = Backbone.View.extend({

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "focus .comment_box": "commentTextareaFocused"
  },

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

    this.delegateEvents(); //we need this because we are explicitly setting this.el in this.render()

    this.$(".comments").html(new App.Views.CommentStream({
      model: this.model
    }).render().el);

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
  },

  focusCommentTextarea: function(evt){
    evt.preventDefault();
    this.$(".new_comment_form_wrapper").removeClass("hidden");
    this.$(".comment_box").focus();

    return this;
  },

  commentTextareaFocused: function(evt){
    this.$("form").removeClass('hidden').addClass("open");
  }

});
