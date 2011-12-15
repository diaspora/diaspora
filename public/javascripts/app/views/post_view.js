App.Views.Post = App.Views.StreamObject.extend({

  template_name: "#stream-element-template",

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "focus .comment_box": "commentTextareaFocused",
    "click .shield a": "removeNsfwShield",
    "click .remove_post": "destroyModel",
    "click .like_action": "toggleLike"
  },

  render: function() {
    this.el = $(this.template($.extend(
      this.model.toJSON(),
      App.user()
    )))[0];

    this.initializeTooltips()
        .renderPostContent()
        .renderComments();

    this.$(".details time").timeago();
    this.delegateEvents(); //we need this because we are explicitly setting this.el in this.render()

    return this;
  },

  renderPostContent: function(){
    var normalizedClass = this.model.get("post_type").replace(/::/, "__");
    var postClass = App.Views[normalizedClass] || App.Views.StatusMessage;
    var postView = new postClass({ model : this.model });

    this.$(".post-content").html(postView.render().el);

    return this;
  },

  renderComments: function(){
    this.$(".comments").html(new App.Views.CommentStream({
      model: this.model
    }).render().el);

    return this;
  },

  removeNsfwShield: function(evt){
    if(evt){ evt.preventDefault(); }

    $(evt.target).parent(".shield").remove();

    return this;
  },

  initializeTooltips: function(){
    $([
      this.$(".delete"),
      this.$(".block_user"),
      this.$(".post_scope")
    ]).map(function() { this.twipsy(); });

    return this;
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }

    var link = $(evt.target);

    if(link.hasClass('like')){
      this.model.likes.create({
        target_id: this.model.get("id"),
        target_type: "post",
        positive: "true"
      });
    }
    else {
      var like = new App.Models.Like({
        "id": this.model.get("user_like")["posts"]["id"],
        target_type: "post",
        target_id: this.model.get("id")
      });

      like.destroy();
    }

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
