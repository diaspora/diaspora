// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.StreamPost = app.views.Post.extend({
  templateName: "stream-element",
  className: "stream-element loaded",

  subviews : {
    ".feedback": "feedbackView",
    ".comments": "commentStreamView",
    ".likes": "likesInfoView",
    ".reshares": "resharesInfoView",
    ".post-controls": "postControlsView",
    ".post-content": "postContentView",
    ".oembed": "oEmbedView",
    ".opengraph": "openGraphView",
    ".poll": "pollView",
    ".status-message-location": "postLocationStreamView"
  },

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "click .show_nsfw_post": "removeNsfwShield",
    "click .toggle_nsfw_state": "toggleNsfwState"
  },

  tooltipSelector : [".timeago",
                     ".post_scope",
                     ".permalink"].join(", "),

  initialize : function(){
    // If we are on a user page, we don't want to remove posts on block
    if (!app.page.model.has("profile")) {
      var personId = this.model.get("author").id;
      app.events.on("person:block:" + personId, this.remove, this);
    }
    //subviews
    this.commentStreamView = new app.views.CommentStream({model : this.model});
    this.oEmbedView = new app.views.OEmbed({model : this.model});
    this.openGraphView = new app.views.OpenGraph({model : this.model});
    this.pollView = new app.views.Poll({model : this.model});
  },

  postControlsView: function() {
    return new app.views.PostControls({model: this.model, post: this});
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

  remove : function() {
    $(this.el).slideUp(400, _.bind(function(){this.$el.remove()}, this));
    app.stream.remove(this.model);
    return this;
  },

  focusCommentTextarea: function(evt){
    evt.preventDefault();
    this.$(".new-comment-form-wrapper").removeClass("hidden");
    this.$(".comment-box").focus();

    return this;
  }
});
// @license-end
