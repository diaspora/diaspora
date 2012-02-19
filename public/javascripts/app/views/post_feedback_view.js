app.views.PostViewerFeedback = app.views.Base.extend({

  templateName: "post-viewer/feedback",

  events : {
    "click .like" : "toggleLike",
    "click .follow" : "toggleFollow",
    "click .reshare" : "reshare",
    "click .comment" : "comment"
  },

  tooltipSelector : ".label",

  toggleLike : function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.toggleLike()
  },

  toggleFollow : function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.toggleFollow()
  },

  reshare : function(evt) {
    if(evt) { evt.preventDefault(); }
    this.model.reshare();
  },

  comment : function(){
    alert('comment')
  }

})

