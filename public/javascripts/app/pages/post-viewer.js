app.pages.PostViewer = app.views.Base.extend({

  templateName: "post-viewer",

  subviews : {
    "#post-content" : "postView",
    "#post-nav" : "navView",
    "#post-feedback" : "feedbackView"
    // "#post-author" : "authorView"
  },

  postView : function(){
    return new app.views.Post({
      model : this.model,
      className : "loaded",
      templateName : this.options.postTemplateName
    })
  },

  navView : function() {
    return new app.views.PostViewerNav({ model : this.model })
  },

  feedbackView : function() {
    if(!window.app.user()) { return null }
    return new app.views.PostViewerFeedback({ model : this.model })
  },

  postRenderTemplate : function() {
    this.setKeyMappings();
  },

  setKeyMappings : function() {
    var nextPostLocation = this.model.get("next_post");
    var previousPostLocation = this.model.get("previous_post");
    var doc = $(document);

    /* focus modal */
    doc.keypress(function(){
      $('#text').focus();
      $('#comment').modal();
    });

    /* navagation hooks */
    doc.keydown(function(e){
      if (e.keyCode == 37 && nextPostLocation) {
        window.location = nextPostLocation

      }else if(e.keyCode == 39 && previousPostLocation) {
        window.location = previousPostLocation
      }
    })
  }

})
