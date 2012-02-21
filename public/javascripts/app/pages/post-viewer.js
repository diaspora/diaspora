app.pages.PostViewer = app.views.Base.extend({

  templateName: "post-viewer",

  subviews : {
    "#post-content" : "postView",
    "#post-nav" : "navView",
    "#post-feedback" : "feedbackView",
    "#header-container" : "authorView"
  },

  postView : function(){
    return new app.views.Post({
      model : this.model,
      className : "loaded",
      templateName : "post-viewer/content/" + this.options.postTemplateName
    })
  },

  navView : function() {
    return new app.views.PostViewerNav({ model : this.model })
  },

  feedbackView : function() {
    if(!window.app.user()) { return null }
    return new app.views.PostViewerFeedback({ model : this.model })
  },

  authorView : function() {
    return new app.views.PostViewerAuthor({ model : this.model })
  },

  postRenderTemplate : function() {
    this.bindNavHooks();
  },

  bindNavHooks : function() {
    /* navagation hooks */
    var nextPostLocation = this.model.get("next_post");
    var previousPostLocation = this.model.get("previous_post");

    $(document).keydown(function(e){
      switch(e.keyCode) {
        case 37:
          navigate(nextPostLocation, "left"); break;
        case 39:
          navigate(previousPostLocation, "right"); break;
        default:
          break;
      }
    })

    function navigate(loc, direction) {
      loc ? window.location = loc : bump(direction)
    }

    function bump(direction) {
      $(".backdrop").addClass("bump-" + direction)
      setTimeout( function(){
        $(".backdrop").removeClass("bump-" + direction)
      }, 200)
    }
  }

})
