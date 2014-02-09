app.views.StreamPost = app.views.Post.extend({
  templateName: "stream-element",
  className : "stream_element loaded",

  subviews : {
    ".feedback" : "feedbackView",
    ".likes" : "likesInfoView",
    ".comments" : "commentStreamView",
    ".post-content" : "postContentView",
    ".oembed" : "oEmbedView",
    ".opengraph" : "openGraphView",
    ".status-message-location" : "postLocationStreamView"
  },

  events: {
    "click .focus_comment_textarea": "focusCommentTextarea",
    "click .show_nsfw_post": "removeNsfwShield",
    "click .toggle_nsfw_state": "toggleNsfwState",

    "click .remove_post": "destroyModel",
    "click .hide_post": "hidePost",
    "click .post_report": "postReport",
    "click .block_user": "blockUser",
    "keydown": "onKeyDown",
    "blur" : "onBlur"
  },

  tooltipSelector : ".timeago, .post_scope, .block_user, .delete",

  initialize : function(){
    this.model.on('remove', this.remove, this);
    //subviews
    this.commentStreamView = new app.views.CommentStream({model : this.model});
    this.oEmbedView = new app.views.OEmbed({model : this.model});
    this.openGraphView = new app.views.OpenGraph({model : this.model});
  },


  likesInfoView : function(){
    return new app.views.LikesInfo({model : this.model});
  },

  feedbackView : function(){
    if(!app.currentUser.authenticated()) { return null; }
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
    if(!confirm(Diaspora.I18n.t('ignore_user'))) { return; }

    var personId = this.model.get("author").id;
    var block = new app.models.Block();

    block.save({block : {person_id : personId}}, {
      success : function(){
        if(!app.stream) { return; }

        _.each(app.stream.posts.models, function(model){
          if(model.get("author").id == personId) {
            app.stream.posts.remove(model);
          }
        });
      }
    });
  },

  remove : function() {
    $(this.el).slideUp(400, _.bind(function(){this.$el.remove();}, this));
    return this;
  },

  hidePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t('confirm_dialog'))) { return; }

    $.ajax({
      url : "/share_visibilities/42",
      type : "PUT",
      data : {
        post_id : this.model.id
      }
    });

    this.remove();
  },

  postReport : function(evt) {
    if(evt) { evt.preventDefault(); }
    var text = prompt(Diaspora.I18n.t('post_report_prompt'),
		      Diaspora.I18n.t('post_report_prompt_default'));

    var postReport = new app.models.PostReport();
    postReport.fetch({
      data: {
        post_id: this.model.id,
        text: text
      },
      type: 'POST'
    });
  },

  focusCommentTextarea: function(evt){
    evt.preventDefault();
    this.$(".new_comment_form_wrapper").removeClass("hidden");
    this.$(".comment_box").focus();

    return this;
  },

  onBlur: function(evt) {
    this.commentStreamView.deselectComment();
  },

  onKeyDown: function(evt) {
    //make sure that the user is not typing in an input field
    var textAcceptingInputTypes = ["textarea", "select", "text", "password", "number", "email", "url", "range", "date", "month", "week", "time", "datetime", "datetime-local", "search", "color"];
    if(jQuery.inArray(event.target.type, textAcceptingInputTypes) > -1){
      return;
    }
    
    // trigger the events based on what key was pressed
    switch (String.fromCharCode( evt.which ).toLowerCase()) {
      case "n":
        this.commentStreamView.selectNextComment();
        break;
      case "p":
        this.commentStreamView.selectPrevComment();
        break;
      default:
    }
  }
});
