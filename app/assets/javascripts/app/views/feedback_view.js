app.views.Feedback = app.views.Base.extend({
  templateName: "feedback",

  className : "info",

  events: {
    "click .like_action" : "toggleLike",
    "click .reshare_action" : "resharePost"
  },

  initialize : function() {
    this.model.interactions.on('change', this.render, this);
  },

  presenter : function() {
    var interactions = this.model.interactions

    return _.extend(this.defaultPresenter(),{
      commentsCount : interactions.commentsCount(),
      likesCount : interactions.likesCount(),
      resharesCount : interactions.resharesCount(),
      userCanReshare : interactions.userCanReshare(),
      userLike : interactions.userLike(),
      userReshare : interactions.userReshare(),
    })
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.interactions.toggleLike();
  },

  resharePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!window.confirm(Diaspora.I18n.t("reshares.post", {name: this.model.reshareAuthor().name}))) { return }
    this.model.interactions.reshare();
  }
});
