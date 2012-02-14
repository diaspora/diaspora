app.views.Feedback = app.views.StreamObject.extend({

  templateName: "feedback",

  className : "info",

  events: {
    "click .like_action": "toggleLike",
    "click .participate_action": "toggleFollow",
    "click .reshare_action": "resharePost"
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
    reshare.save({}, {
      url: this.model.createReshareUrl,
      success : function(){
        app.stream.add(reshare);
      }
    });
  },

  userCanReshare : function() {
    var isReshare = this.model.get("post_type") == "Reshare"
    var rootExists = (isReshare ? this.model.get("root") : true)

    var publicPost = this.model.get("public");
    var userIsNotAuthor = this.model.get("author").diaspora_id != app.user().diaspora_id;
    var userIsNotRootAuthor = rootExists && (isReshare ? this.model.get("root").author.diaspora_id != app.user().diaspora_id : true)

    return publicPost && userIsNotAuthor && userIsNotRootAuthor;
  }
})
