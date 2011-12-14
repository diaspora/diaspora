App.Views.Post = App.Views.StreamObject.extend({

  template_name: "#stream-element-template",

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "focus .comment_box": "commentTextareaFocused",
    "click .delete:first": "destroyModel"
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
