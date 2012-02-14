app.views.Post = app.views.StreamObject.extend({

  templateName: "stream-element",

  className : "stream_element loaded",

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "click .nsfw-shield a": "removeNsfwShield",
    "click .remove_post": "destroyModel",
    "click .hide_post": "hidePost",
    "click .block_user": "blockUser"
  },

  subviews : {
    ".feedback" : "feedbackView",
    ".likes" : "likesInfoView",
    ".comments" : "commentStreamView",
    ".post-content" : "postContentView"
  },

  tooltipSelector : ".delete, .block_user, .post_scope",

  initialize : function() {
    $(this.el).attr("id", this.model.get("guid"));

    this.model.bind('remove', this.remove, this);

    //subviews
    this.commentStreamView = new app.views.CommentStream({ model : this.model});

    return this;
  },

  likesInfoView : function(){
    return new app.views.LikesInfo({ model : this.model});
  },

  feedbackView : function(){
    if(!window.app.user()) { return null }
    return new  app.views.Feedback({model : this.model});
  },

  postContentView: function(){
    var normalizedClass = this.model.get("post_type").replace(/::/, "__");
    var postClass = app.views[normalizedClass] || app.views.StatusMessage;
    return new postClass({ model : this.model });
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser : this.authorIsCurrentUser()
    })
  },

  removeNsfwShield: function(evt){
    if(evt){ evt.preventDefault(); }
    this.model.set({nsfw : false})
    this.render();
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

        _.each(app.stream.posts.models, function(model){
          if(model.get("author").id == personId) {
            app.stream.posts.remove(model);
          }
        })
      }
    })
  },

  hidePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t('confirm_dialog'))) { return }

    $.ajax({
      url : "/share_visibilities/42",
      type : "PUT",
      data : {
        post_id : this.model.id
      }
    })

    this.slideAndRemove();
  },

  focusCommentTextarea: function(evt){
    evt.preventDefault();
    this.$(".new_comment_form_wrapper").removeClass("hidden");
    this.$(".comment_box").focus();

    return this;
  },

  authorIsCurrentUser : function() {
    return this.model.get("author").id != (!!app.user() && app.user().id)
  }
});
