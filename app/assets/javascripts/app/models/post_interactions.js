// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.models.PostInteractions = app.models.LikeInteractions.extend({
  initialize: function(options) {
    app.models.LikeInteractions.prototype.initialize.apply(this, arguments);
    this.post = options.post;
    this.comments = new app.collections.Comments(this.get("comments"), {post: this.post});
    this.reshares = new app.collections.Reshares(this.get("reshares"), {post: this.post});
  },

  resharesCount: function() {
    return this.get("reshares_count");
  },

  commentsCount: function() {
    return this.get("comments_count");
  },

  userReshare: function() {
    return this.reshares.select(function(reshare){
      return reshare.get("author") && reshare.get("author").guid === app.currentUser.get("guid");
    })[0];
  },

  comment: function(text, options) {
    var self = this;
    options = options || {};

    this.comments.make(text).fail(function(response) {
      app.flashMessages.handleAjaxError(response);
      if (options.error) { options.error(); }
    }).done(function() {
      self.post.set({participation: true});
      self.set({"comments_count": self.get("comments_count") + 1});
      self.trigger('change'); //updates after sync
      if (options.success) { options.success(); }
    });
  },

  removedComment: function() {
    this.set({"comments_count": this.get("comments_count") - 1});
  },

  reshare : function(){
    var interactions = this;

    this.post.reshare().save()
      .done(function(reshare) {
        app.flashMessages.success(Diaspora.I18n.t("reshares.successful"));
        interactions.reshares.add(reshare);
        interactions.post.set({participation: true});
        if (app.stream && /^\/(?:stream|activity|aspects)/.test(app.stream.basePath())) {
          app.stream.addNow(reshare);
        }
        interactions.trigger("change");
        interactions.set({"reshares_count": interactions.get("reshares_count") + 1});
        interactions.reshares.trigger("change");
      })
      .fail(function(response) {
        app.flashMessages.handleAjaxError(response);
      });
  },

  userCanReshare: function() {
    var isReshare = this.post.get("post_type") === "Reshare"
      , rootExists = (isReshare ? this.post.get("root") : true)
      , publicPost = this.post.get("public")
      , userIsNotAuthor = this.post.get("author").diaspora_id !== app.currentUser.get("diaspora_id")
      , userIsNotRootAuthor = rootExists && (isReshare ? this.post.get("root").author.diaspora_id !== app.currentUser.get("diaspora_id") : true)
      , notReshared = !this.userReshare();

    return publicPost && app.currentUser.authenticated() && userIsNotAuthor && userIsNotRootAuthor && notReshared;
  }
});
// @license-end
