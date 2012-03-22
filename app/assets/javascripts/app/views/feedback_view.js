app.views.Feedback = app.views.Base.extend({

  templateName: "feedback",

  className : "info",

  events: {
    "click .like_action" : "toggleLike",
    "click .participate_action" : "toggleFollow",
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

  toggleFollow : function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.toggleFollow();
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.toggleLike();
  },

  resharePost : function(evt) {
    if(evt) { evt.preventDefault(); }
    if(!window.confirm("Reshare " + this.model.reshareAuthor().name + "'s post?")) { return }
    var reshare = this.model.reshare()
    var model = this.model

    reshare.save({}, {
      url: this.model.createReshareUrl,
      success : function(resp){
        app.stream && app.stream.add(reshare);
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
