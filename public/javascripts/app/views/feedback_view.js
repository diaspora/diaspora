app.views.Feedback = app.views.StreamObject.extend({

  templateName: "feedback",

  className : "info",

  events: {
    "click .like_action": "toggleLike",
    "click .participate_action": "toggleFollow",
    "click .reshare_action": "resharePost"
  },

  initialize: function() {
    this.model.bind('change', this.render, this);
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
      url: this.model.get("post").createReshareUrl,
      success : function(){
        app.stream.add(reshare);
      }
    });
  },

  userCanReshare : function() {
    var isReshare = this.model.get("post").get("post_type") == "Reshare"
    var rootExists = (isReshare ? this.model.get("post").get("root") : true)

    var publicPost = this.model.get("post").get("public");
    var userIsNotAuthor = this.model.get("post").get("author").diaspora_id != app.user().get("diaspora_id");
    var userIsNotRootAuthor = rootExists && (isReshare ? this.model.get("post").get("root").author.diaspora_id != app.user().get("diaspora_id") : true)

    return publicPost && userIsNotAuthor && userIsNotRootAuthor;
  }
})
