app.views.Feedback = app.views.Base.extend({
  templateName: "feedback",

  className : "info",

  events: {
    "click *[rel='auth-required']" : "requireAuth",
    "click .like" : "toggleLike",
    "click .reshare" : "resharePost"
  },

  tooltipSelector : ".label",

  initialize : function() {
    this.model.interactions.on('change', this.render, this);
    this.initViews && this.initViews() // I don't know why this was failing with $.noop... :(
  },

  presenter : function() {
    var interactions = this.model.interactions

    return _.extend(this.defaultPresenter(),{
      commentsCount : interactions.commentsCount(),
      likesCount : interactions.likesCount(),
      resharesCount : interactions.resharesCount(),
      userCanReshare : interactions.userCanReshare(),
      userLike : interactions.userLike(),
      userReshare : interactions.userReshare()
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
  },

  requireAuth : function(evt) {
    if( app.currentUser.authenticated() ) { return }
    alert("you must be logged in to do that!")
    return false;
  }
});
