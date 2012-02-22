app.views.PostViewerReactions = app.views.Base.extend({

  className : "",

  templateName: "post-viewer/reactions",

  events : { },

  initialize : function() {
    this.model.bind('interacted', this.render, this);
  },

})
