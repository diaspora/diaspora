app.views.SinglePostInteractions = app.views.Base.extend({
  templateName: "single-post-viewer/single-post-interactions",
  tooltipSelector: ".avatar.micro",

  subviews: {
    '#comments': 'commentStreamView'
  },

  initialize : function() {
    this.model.interactions.on('change', this.render, this);
    this.commentStreamView = new app.views.SinglePostCommentStream({model: this.model})
  },

  presenter : function(){
    var interactions = this.model.interactions
    return {
      likes : interactions.likes.toJSON(),
      comments : interactions.comments.toJSON(),
      reshares : interactions.reshares.toJSON(),
      commentsCount : interactions.commentsCount(),
      likesCount : interactions.likesCount(),
      resharesCount : interactions.resharesCount(),
    }
  },
});
