// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.StreamPost = app.views.Post.extend({
  templateName: "stream-element",
  className : "stream_element loaded",

  subviews : {
    ".feedback" : "feedbackView",
    ".likes" : "likesInfoView",
    ".reshares" : "resharesInfoView",
    ".comments" : "commentStreamView",
    ".post-content" : "postContentView",
    ".oembed" : "oEmbedView",
    ".opengraph" : "openGraphView",
    ".poll" : "pollView",
    ".status-message-location" : "postLocationStreamView"
  },

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "click .show_nsfw_post": "removeNsfwShield",
    "click .toggle_nsfw_state": "toggleNsfwState",

    "click .remove_post": "destroyModel",
    "click .hide_post": "hidePost",
    "click .post_report": "report",
    "click .block_user": "blockUser",

    "click .create_participation": "createParticipation",
    "click .destroy_participation": "destroyParticipation"
  },

  tooltipSelector : [".timeago",
                     ".post_scope",
                     ".post_report",
                     ".block_user",
                     ".delete",
                     ".create_participation",
                     ".destroy_participation",
                     ".permalink"].join(", "),

  initialize : function(){
    var personId = this.model.get("author").id;
    app.events.on("person:block:"+personId, this.remove, this);

    this.model.on("remove", this.remove, this);
    //subviews
    this.commentStreamView = new app.views.CommentStream({model : this.model});
    this.oEmbedView = new app.views.OEmbed({model : this.model});
    this.openGraphView = new app.views.OpenGraph({model : this.model});
    this.pollView = new app.views.Poll({model : this.model});
  },


  likesInfoView : function(){
    return new app.views.LikesInfo({model : this.model});
  },

  resharesInfoView : function(){
    return new app.views.ResharesInfo({model : this.model});
  },

  feedbackView : function(){
    if(!app.currentUser.authenticated()) { return null }
    return new app.views.Feedback({model : this.model});
  },

  postContentView: function(){
    var normalizedClass = this.model.get("post_type").replace(/::/, "__")
      , postClass = app.views[normalizedClass] || app.views.StatusMessage;

    return new postClass({ model : this.model });
  },

  postLocationStreamView : function(){
    return new app.views.LocationStream({ model : this.model});
  },

  removeNsfwShield: function(evt){
    if(evt){ evt.preventDefault(); }
    this.model.set({nsfw : false});
    this.render();
  },

  toggleNsfwState: function(evt){
    if(evt){ evt.preventDefault(); }
    app.currentUser.toggleNsfwState();
  },


  blockUser: function(evt){
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t("ignore_user"))) { return }

    this.model.blockAuthor()
      .fail(function() {
        app.flashMessages.error(Diaspora.I18n.t("ignore_failed"));
      });
  },

  remove : function() {
    $(this.el).slideUp(400, _.bind(function(){this.$el.remove()}, this));
    app.stream.remove(this.model);
    return this;
  },

  hidePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t("confirm_dialog"))) { return }

    var self = this;
    $.ajax({
      url : "/share_visibilities/42",
      type : "PUT",
      data : {
        post_id : this.model.id
      }
    }).done(function() {
        self.remove();
      })
      .fail(function() {
        app.flashMessages.error(Diaspora.I18n.t("hide_post_failed"));
      });
  },

  createParticipation: function (evt) {
    if(evt) { evt.preventDefault(); }
    var that = this;
    $.post(Routes.postParticipation(this.model.get("id")), {}, function () {
      that.model.set({participation: true});
      that.render();
    });
  },

  destroyParticipation: function (evt) {
    if(evt) { evt.preventDefault(); }
    var that = this;
    $.post(Routes.postParticipation(this.model.get("id")), { _method: "delete" }, function () {
      that.model.set({participation: false});
      that.render();
    });
  },

  focusCommentTextarea: function(evt){
    evt.preventDefault();
    this.$(".new-comment-form-wrapper").removeClass("hidden");
    this.$(".comment_box").focus();

    return this;
  }

});
// @license-end
