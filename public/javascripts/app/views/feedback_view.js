app.views.Feedback = app.views.StreamObject.extend({
  template_name: "#feedback-template",

  className : "info",

  events: {
    "click .like_action": "toggleLike",
    "click .reshare_action": "resharePost"
  },

  toggleLike: function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.toggleLike();
  },

  resharePost : function(evt){
    if(evt) { evt.preventDefault(); }
    if(!window.confirm("Reshare " + this.model.reshareAuthor().name + "'s post?")) { return }
    var reshare = this.model.reshare()
    reshare.save({}, {
      url: this.model.createReshareUrl,
      success : function(){
        app.stream.add(reshare);
      }
    });
  }
})
