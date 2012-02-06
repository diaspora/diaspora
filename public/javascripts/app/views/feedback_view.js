app.views.Feedback = app.views.StreamObject.extend({

  templateName: "feedback",

  className : "info",

  events: {
    "click .like_action": "toggleLike",
    "click .reshare_action": "resharePost"
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
    var publicPost = this.model.get("public");
    var userIsNotAuthor = this.model.get("author").id != app.user().id;
    var rootExists = (this.model.get("post_type") == "Reshare" ? this.model.get("root") : true);
    
    return publicPost && userIsNotAuthor && rootExists;
  }
})
