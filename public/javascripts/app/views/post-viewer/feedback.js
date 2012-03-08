app.views.PostViewerFeedback = app.views.Feedback.extend({

  id : "user-controls",
  className : "",

  templateName: "post-viewer/feedback",

  events : {
    "click *[rel='auth-required']" : "requireAuth",

    "click .like" : "toggleLike",
    "click .follow" : "toggleFollow",
    "click .reshare" : "resharePost",

    "click *[rel='invoke-interaction-pane']" : "invokePane",
    "click *[rel='hide-interaction-pane']" : "hidePane"
  },

  tooltipSelector : ".label, .home-button",

  postRenderTemplate : function() {
    this.sneakyVisiblity()
  },

  sneakyVisiblity : function() {
    if(!$("#post-info").is(":visible")) {
      this.$("#post-info-sneaky").removeClass('passive')
    }
  },

  invokePane : function(evt){ this.trigger("invokePane") },
  hidePane : function(evt){ this.trigger("hidePane") },

  requireAuth : function(evt) {
    if( app.currentUser.authenticated() ) { return }
    alert("you must be logged in to do that!")
    return false;
  }

});