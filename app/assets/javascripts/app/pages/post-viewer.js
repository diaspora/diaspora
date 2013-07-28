app.pages.PostViewer = app.views.Base.extend({
  templateName: "post-viewer",

  subviews : {
    "#post-content" : "postView",
    "#post-nav" : "navView",
    "#post-interactions" : "interactionsView",
    "#author-info" : "authorView"
  },

  initialize : function(options) {
    this.model = new app.models.Post({ id : options.id });
    this.model.preloadOrFetch().done(_.bind(this.initViews, this));
    this.model.interactions.fetch() //async, yo, might want to throttle this later.

    this.bindEvents()
  },

  initViews : function() {
    /* init view */
    this.authorView = new app.views.PostViewerAuthor({ model : this.model });
    this.interactionsView = new app.views.PostViewerInteractions({ model : this.model });
    this.navView = new app.views.PostViewerNav({ model : this.model });
    this.postView = app.views.Post.showFactory(this.model)

    this.render();
  },

  bindEvents : function(){
    this.prepIdleHooks();
    this.bindNavHooks();

    $(document).bind("keypress", _.bind(this.commentAnywhere, this))
    $(document).bind("keypress", _.bind(this.invokePane, this))
    $(document).bind("keyup", _.bind(this.closePane, this))
  },

  unbind : function(){
    $(document).unbind("idle.idleTimer")
    $(document).unbind("active.idleTimer")
    $(document).unbind('keydown')
    $(document).unbind('keypress')
    $(document).unbind('keyup')
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

  bindNavHooks : function() {
    var model = this.model;
    $(document).keydown(function(evt){
      // prevent nav from happening if the user is using the arrow keys to navigate through their comment text
      if($(evt.target).is("textarea")) { return }

      switch(evt.keyCode) {
        case KEYCODES.LEFT:
          app.router.navigate(model.get("next_post"), true); break;
        case KEYCODES.RIGHT:
          app.router.navigate(model.get("previous_post"), true); break;
        default:
          break;
      }
    })
  },

  postRenderTemplate : function() {
    if(this.model.get("title")){
      // formats title to html...
      var html_title = app.helpers.textFormatter(this.model.get("title"), this.model);
      //... and converts html to plain text 
      document.title = $('<div>').html(html_title).text(); 
    }
  },

  commentAnywhere : function(evt) {
    /* ignore enter, space bar, arrow keys */
    if(_.include([KEYCODES.RETURN, KEYCODES.SPACE, KEYCODES.LEFT,
                  KEYCODES.UP, KEYCODES.RIGHT, KEYCODES.DOWN], evt.keyCode) ||
        this.modifierPressed(evt) ) { return }

    this.interactionsView.invokePane();
    $('#new-post-comment textarea').focus();
  },

  invokePane : function(evt) {
    if(evt.keyCode != KEYCODES.SPACE) { return }
    this.interactionsView.invokePane();
  },

  closePane : function(evt) {
    if(evt.keyCode != KEYCODES.ESC) { return }
    this.interactionsView.hidePane();
  },

  modifierPressed: function(evt) {
    return (evt.altKey || evt.ctrlKey || evt.shiftKey);
  }
});
