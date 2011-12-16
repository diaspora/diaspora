App.Views.Post = App.Views.StreamObject.extend({

  template_name: "#stream-element-template",

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "click .shield a": "removeNsfwShield",
    "click .remove_post": "destroyModel",
    "click .like_action": "toggleLike",
    "click .expand_likes": "expandLikes",
    "click .block_user": "blockUser"
  },

  render: function() {
    this.renderTemplate()
        .initializeTooltips()
        .renderPostContent()
        .renderComments();

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
    var post = this.model;

    if(link.hasClass('like')) {
      var like = this.model.likes.create();
      if(like) {
        this.model.set({
          user_like : like,
          likes_count : post.get("likes_count") + 1
        });
      }
    } else {
      this.model.likes.get(link.data("id")).destroy({
        success : function(){
          post.set({
            user_like : null,
            likes_count : post.get("likes_count") - 1
          });
        }
      });
    }

    return this;
  },

  expandLikes: function(evt){
    if(evt) { evt.preventDefault(); }

    var self = this;

    this.model.likes.fetch({
      success: function(){
        // this should be broken out

        self.$(".expand_likes").remove();
        var likesView = Backbone.View.extend({

          tagName: 'span',

          initialize: function(options){
            this.collection = options.collection;
            _.bindAll(this, "render", "appendLike");
          },

          render: function(){
            _.each(this.collection.models, this.appendLike)
            return this;
          },

          appendLike: function(model){
            $(this.el).append("<a>", {
              href : "/person/" + model.get("author")["id"]
            }).html($("<img>", {
              src : model.get("author")["avatar"]["small"],
              "class" : "avatar"
            }));
          }
        });

        var view = new likesView({collection : self.model.likes});

        self.$('.likes_container').removeClass("hidden")
                             .append(view.render().el);

      }
    });

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
  }
});
