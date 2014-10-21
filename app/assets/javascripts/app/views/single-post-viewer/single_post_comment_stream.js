// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.SinglePostCommentStream = app.views.CommentStream.extend({
  tooltipSelector: "time, .controls a",

  initialize: function(){
    $(window).on('hashchange',this.highlightPermalinkComment);
  },
 
  highlightPermalinkComment: function() {
    if(document.location.hash){
      element=$(document.location.hash);
      headerSize=50;
      $(".highlighted").removeClass("highlighted");
      element.addClass("highlighted");
      pos=element.offset().top-headerSize;
      $("html").animate({scrollTop:pos});
    }
  },

  postRenderTemplate: function() {
    app.views.CommentStream.prototype.postRenderTemplate.apply(this)
    this.$(".new_comment_form_wrapper").removeClass('hidden')
    _.defer(this.highlightPermalinkComment)
  },

  appendComment: function(comment) {
    // Set the post as the comment's parent, so we can check
    // on post ownership in the Comment view.
    comment.set({parent : this.model.toJSON()})

    this.$(".comments").append(new app.views.ExpandedComment({
      model: comment
    }).render().el);
  },

  presenter: function(){
    return _.extend(this.defaultPresenter(), {
      moreCommentsCount : 0,
      showExpandCommentsLink : false,
      commentsCount : this.model.interactions.commentsCount()
    })
  },
})
// @license-end

