app.views.Post = app.views.StreamObject.extend({

  template_name: "#stream-element-template",

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

    if(confirm('Ignore this user?')) {
      var person_id = $(evt.target).data('person_id');
      var self = this;

      $.post('/blocks', {block : {"person_id" : person_id}}, function(data){
        var models_to_remove = [];

        _.each(self.model.collection.models, function(model){
          if(model.get("author")["id"] == person_id) {
            models_to_remove.push(model);
          }
        })

        self.model.collection.remove(models_to_remove);
      }, "json");
    }

    return this;
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
