app.views.PostViewerReactions = app.views.Base.extend({

  className : "",

  templateName: "post-viewer/reactions",

  tooltipSelector : ".avatar",

  initialize : function() {
    this.model.on('change', this.render, this);
    this.model.comments.bind("add", this.appendComment, this)
  },

  presenter : function(){
    return {
      likes : this.model.likes.toJSON(),
      comments : this.model.comments.toJSON(),
      reshares : this.model.reshares.toJSON()
    }
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
    // Set the post as the comment's parent, so we can check on post ownership in the Comment view.
    // model was post on old view, is interactions on new view

    var parent = this.model.get("post_type") ? this.model.toJSON : this.model.post.toJSON()
    comment.set({parent : parent})

    this.$("#post-comments").append(new app.views.Comment({
      model: comment,
      className : "post-comment media",
      templateName : "post-viewer/comment"
    }).render().el);
  }
});
