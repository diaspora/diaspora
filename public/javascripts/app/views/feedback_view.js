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
    if(!window.confirm("Reshare " + this.model.baseAuthor().name + "'s post?")) { return }

    var reshare = new app.models.Reshare();
    reshare.save({root_guid : this.model.baseGuid()}, {
      success : function(){
        app.stream.collection.add(reshare.toJSON());
      }
    });
    return reshare;
  }
})
