// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.SinglePostActions = app.views.Feedback.extend({
  templateName: "single-post-viewer/single-post-actions",

  events: function() {
    return _.defaults({
      "click .focus-comment" : "focusComment"
    }, app.views.Feedback.prototype.events);
  },

  presenter: function() {
    var interactions = this.model.interactions;

    return _.extend(this.defaultPresenter(), {
      authorIsNotCurrentUser : this.authorIsNotCurrentUser(),
      userCanReshare : interactions.userCanReshare(),
      userLike : interactions.userLike(),
      userReshare : interactions.userReshare()
    });
  },

  renderPluginWidgets : function() {
    app.views.Base.prototype.renderPluginWidgets.apply(this);
    this.$('a').tooltip({placement: 'bottom'});
  },

  focusComment: function() {
    $('.comment_stream .comment-box').focus();
    $('html,body').animate({scrollTop: $('.comment_stream .comment-box').offset().top - ($('.comment_stream .comment-box').height() + 20)});
    return false;
  },

  authorIsNotCurrentUser: function() {
    return app.currentUser.authenticated() && this.model.get("author").id !== app.user().id;
  }
});
// @license-end
