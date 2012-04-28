app.views.Feedback = app.views.Base.extend({

  templateName: "feedback",

  className : "info",

  events: {
    "click .like_action" : "toggleLike",
    "click .reshare_action" : "resharePost"
  },

  initialize : function() {
    this.model.bind('interacted', this.render, this);
  },

  presenter : function() {
    return _.extend(this.defaultPresenter(), {
      userCanReshare : this.userCanReshare()
    })
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.toggleLike();
  },

  resharePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!window.confirm(Diaspora.I18n.t("reshares.post", {name: this.model.reshareAuthor().name}))) { return }
    var reshare = this.model.reshare()
    var model = this.model

    reshare.save({}, {
      url: this.model.createReshareUrl,
      success : function(resp){
        var flash = new Diaspora.Widgets.FlashMessages;
        flash.render({
          success: true,
          notice: Diaspora.I18n.t("reshares.successful")
        });
        model.trigger("interacted")
      }
    });
  },

  userCanReshare : function() {
    var isReshare = this.model.get("post_type") == "Reshare"
    var rootExists = (isReshare ? this.model.get("root") : true)

    var publicPost = this.model.get("public");
    var userIsNotAuthor = this.model.get("author").diaspora_id != app.currentUser.get("diaspora_id");
    var userIsNotRootAuthor = rootExists && (isReshare ? this.model.get("root").author.diaspora_id != app.currentUser.get("diaspora_id") : true)

    return publicPost && app.currentUser.authenticated() && userIsNotAuthor && userIsNotRootAuthor;
  }
});
