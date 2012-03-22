app.pages.PostViewer = app.views.Base.extend({

  templateName: "post-viewer",

  subviews : {
    "#post-content" : "postView",
    "#post-nav" : "navView",
    "#post-interactions" : "interactionsView",
    "#header-container" : "authorView"
  },

  initialize : function(options) {
    this.model = new app.models.Post({ id : options.id });
    this.model.fetch().success(_.bind(this.initViews, this));

    this.prepIdleHooks();

    $(document).bind("keypress", _.bind(this.commentAnywhere, this))
    $(document).bind("keypress", _.bind(this.invokePane, this))
    $(document).bind("keyup", _.bind(this.closePane, this))
  },

  initViews : function() {
    /* init view */
    this.authorView = new app.views.PostViewerAuthor({ model : this.model });
    this.interactionsView = new app.views.PostViewerInteractions({ model : this.model });
    this.navView = new app.views.PostViewerNav({ model : this.model });
    this.postView = new app.views.Post({
      model : this.model,
      className : this.model.get("templateName") + " post loaded",
      templateName : "post-viewer/content/" + this.model.get("templateName"),
      attributes : {"data-template" : this.model.get("templateName")}
    });

    this.render();
  },

  prepIdleHooks : function () {
    $.idleTimer(3000);

    $(document).bind("idle.idleTimer", function(){
      $("body").addClass('idle');
    });

    $(document).bind("active.idleTimer", function(){
      $("body").removeClass('idle');
    });
  },

  postRenderTemplate : function() {
    /* set the document title */
    console.log(this.model)
    document.title = this.model.get("title");

    this.bindNavHooks();
  },

  bindNavHooks : function() {
    /* navagation hooks */
    var nextPostLocation = this.model.get("next_post");
    var previousPostLocation = this.model.get("previous_post");


    $(document).keydown(function(evt){
      /* prevent nav from happening if the user is using the arrow
       * keys to navigate through their comment text */
      if($(evt.target).is("textarea")) { return }

      switch(evt.keyCode) {
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
    /* ignore enter, space bar, arrow keys */
    if(_.include([13, 32, 37, 38, 39, 40], evt.keyCode)) { return }

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

});
