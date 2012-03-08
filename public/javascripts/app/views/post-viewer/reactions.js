app.views.PostViewerReactions = app.views.Base.extend({

  className : "",

  templateName: "post-viewer/reactions",

  tooltipSelector : ".avatar",

  initialize : function() {
    this.model.bind('interacted', this.render, this);
  },

  postRenderTemplate : function() {
    this.populateComments()
  },

  /* copy pasta from commentStream */
  populateComments : function() {
    this.model.comments.each(this.appendComment, this)
  },

  /* copy pasta from commentStream */
  appendComment: function(comment) {
    // Set the post as the comment's parent, so we can check
    // on post ownership in the Comment view.
    comment.set({parent : this.model.toJSON()})

    this.$("#post-comments").append(new app.views.Comment({
      model: comment,
      className : "post-comment media"
    }).render().el);
  }

});