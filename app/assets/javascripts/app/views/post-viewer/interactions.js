app.views.PostViewerInteractions = app.views.Base.extend({

  className : "",

  subviews : {
    "#post-feedback" : "feedbackView",
    "#post-reactions" : "reactionsView",
    "#new-post-comment" : "newCommentView"
  },

  templateName: "post-viewer/interactions",

  initialize : function() {
    this.initViews();

    this.feedbackView && this.feedbackView.bind("invokePane", this.invokePane, this)
    this.feedbackView && this.feedbackView.bind("hidePane", this.hidePane, this)
  },

  initViews : function() {
    this.reactionsView = new app.views.PostViewerReactions({ model : this.model.interactions })

    /* subviews that require user */
    this.feedbackView = new app.views.PostViewerFeedback({ model : this.model })
    if(app.currentUser.authenticated()) {
      this.newCommentView = new app.views.PostViewerNewComment({ model : this.model })
    }
  },

  togglePane : function(evt) {
    if(evt) { evt.preventDefault() }
    $("#post-interactions").toggleClass("active")
    this.$("#post-info").slideToggle(300)
    this.removeTooltips()
  },

  invokePane : function() {
    if(!this.$("#post-info").is(":visible")) {
      this.$("#post-info-sneaky").addClass("passive")
      this.togglePane()
    }
  },

  hidePane : function() {
    if(this.$("#post-info").is(":visible")) {

      /* it takes about 400ms for the pane to hide.  we need to keep
       * the sneaky hidden until the slide is complete */
      setTimeout(function(){
        this.$("#post-info-sneaky").removeClass("passive")
      }, 400)

      this.togglePane()
    }
  }
});