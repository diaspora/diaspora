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

  initialize: function(options){
    this.setupRenderEvents();
    this.reshareablePost = options.model;
  },

  resharePost : function(evt){
    if(evt) { evt.preventDefault(); }
    if(!window.confirm("Reshare " + this.reshareablePost.baseAuthor().name + "'s post?")) { return }
    this.reshareablePost.reshare();
  }
})
