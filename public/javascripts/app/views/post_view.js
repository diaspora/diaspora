app.views.Post = app.views.StreamObject.extend({

  template_name: "#stream-element-template",

  className : "stream_element loaded",

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "click .shield a": "removeNsfwShield",
    "click .remove_post": "destroyModel",
    "click .block_user": "blockUser"
  },

  subviews : {
    ".feedback" : "feedbackView",
    ".likes" : "likesInfoView",
    ".comments" : "commentStreamView"
  },

  tooltips : [
    ".delete",
    ".block_user",
    ".post_scope"
  ],

  initialize : function() {
    // set the guid
    $(this.el).attr("id", this.model.get("guid"));

    // remove post
    this.model.bind('remove', this.remove, this);

    // commentStream view
    this.commentStreamView = new app.views.CommentStream({ model : this.model});
    this.likesInfoView = new app.views.LikesInfo({ model : this.model});

    // feedback view
    if(window.app.user().current_user) {
      this.feedbackView = new app.views.Feedback({model : this.model});
    } else {
      this.feedbackView = null;
    }

    return this;
  },

  postRenderTemplate : function() {
    this.renderPostContent()
        .initializeTooltips()
        .$(".details time")
          .timeago();

    return this;
  },

  renderPostContent: function(){
    var normalizedClass = this.model.get("post_type").replace(/::/, "__");
    var postClass = app.views[normalizedClass] || app.views.StatusMessage;
    var postView = new postClass({ model : this.model });

    this.$(".post-content").html(postView.render().el);

    return this;
  },

  removeNsfwShield: function(evt){
    if(evt){ evt.preventDefault(); }

    $(evt.target).parent(".shield").remove();

    return this;
  },

  blockUser: function(evt){
    if(evt) { evt.preventDefault(); }
    if(!confirm("Ignore this user?")) { return }

    var personId = this.model.get("author").id;
    var block = new app.models.Block();

    block.save({block : {person_id : personId}}, {
      success : function(){
        if(!app.stream) { return }

        _.each(app.stream.collection.models, function(model){
          if(model.get("author").id == personId) {
            app.stream.collection.remove(model);
          }
        })
      }
    })
  },

  focusCommentTextarea: function(evt){
    evt.preventDefault();
    this.$(".new_comment_form_wrapper").removeClass("hidden");
    this.$(".comment_box").focus();

    return this;
  },

  initializeTooltips: function(){
    _.each(this.tooltips, function(selector, options){
      this.$(selector).twipsy(options);
    }, this);

    return this;
  }
});
