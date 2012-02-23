app.pages.PostViewer = app.views.Base.extend({

  templateName: "post-viewer",

  subviews : {
    "#post-content" : "postView",
    "#post-nav" : "navView",
    "#post-feedback" : "interactionsView",
    "#header-container" : "authorView"
  },

  initialize : function() {
    this.initViews();

    $(document).bind("keypress", _.bind(this.commentAnywhere, this))
    $(document).bind("keypress", _.bind(this.invokePane, this))
    $(document).bind("keyup", _.bind(this.closePane, this))
  },

  initViews : function() {
    this.authorView = new app.views.PostViewerAuthor({ model : this.model });
    this.interactionsView = new app.views.PostViewerInteractions({ model : this.model });
    this.navView = new app.views.PostViewerNav({ model : this.model });

    this.postView = new app.views.Post({
      model : this.model,
      className : "post loaded",
      templateName : "post-viewer/content/" + this.options.postTemplateName,
      attributes : {"data-template" : this.options.postTemplateName}
    });
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
          navigate(nextPostLocation); break;
        case 39:
          navigate(previousPostLocation); break;
        default:
          break;
      }
    })

    function navigate(loc) {
      loc ? window.location = loc : null
    }
  },

  commentAnywhere : function(evt) {
    /* ignore enter and space bar */
    if(evt.keyCode == 13 || evt.keyCode == 32) { return }

    this.interactionsView.invokePane();
    $('#new-post-comment textarea').focus();
  },

  invokePane : function(evt) {
    if(evt.keyCode != 32) { return }

    this.interactionsView.invokePane();
  },

  closePane : function(evt) {
    if(evt.keyCode != 27) { return }
    this.interactionsView.hidePane();
  }

})
