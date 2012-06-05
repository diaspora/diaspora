//= require ../views/profile_info_view

app.pages.Profile = app.views.Base.extend({
  templateName : "profile",
  id : "profile",

  subviews : {
    "#profile-info" : "profileInfo",
    "#canvas" : "canvasView",
    "#wallpaper-upload" : "wallpaperForm",
    "#composer" : "composerView"
  },

  events : {
    "click #edit-mode-toggle" : "toggleEdit",
    "click #logout-button" : "logOutConfirm",
    "click #composer-button" : "showComposer"
  },

  tooltipSelector : "*[rel=tooltip]",

  personGUID : null,
  editMode : false,
  composeMode : false,

  initialize : function(options) {
    this.personGUID = options.personId

    this.model = this.model || app.models.Profile.preloadOrFetch(this.personGUID)
    this.stream = options && options.stream || new app.models.Stream()
    this.stream.preloadOrFetch()

    this.initViews()

    /* binds */
    this.stream.items.bind("remove", this.pulsateNewPostControl, this)
    $(window).on("keydown", _.bind(this.closeComposer, this))
  },

  initViews : function(){
    this.canvasView = new app.views.Canvas({ model : this.stream })
    this.wallpaperForm = new app.forms.Wallpaper()
    this.profileInfo = new app.views.ProfileInfo({ model : this.model })
    this.composerView = new app.pages.Composer();
  },

  render :function () {
    var self = this;
    this.model.deferred
      .done(function () {
        self.setPageTitleAndBackground()
        app.views.Base.prototype.render.call(self)
      })
      .done(function () {
        self.stream.deferred.done(_.bind(self.pulsateNewPostControl, self));
      })

    return self
  },

  presenter : function(){
    var bio =  this.model.get("bio") || ''

    return _.extend(this.defaultPresenter(),
      {text : this.model && app.helpers.textFormatter(bio, this.model) })
  },

  pulsateNewPostControl : function() {
    this.$("#composer-button")[
      this.stream.items.length == 0
        ? 'addClass'
        : 'removeClass'
      ]("pulse")
  },

  setPageTitleAndBackground : function() {
    console.log(this.model.attributes)
    if(this.model.get("name")) {
      document.title = this.model.get("name")
      this.$el.css("background-image", "url(" + this.model.get("wallpaper") + ")")
    }
  },

  toggleEdit : function(evt) {
    if(evt) { evt.preventDefault() }
    this.editMode = !this.editMode
    this.$el.toggleClass("edit-mode")
  },

  showComposer : function(evt) {
    if(evt) { evt.preventDefault() }

    this.toggleComposer()
    this.$("#post_text").focus()

    app.router.navigate("/posts/new")
  },

  closeComposer : function(evt) {
    if(!evt) { return }

    if(this.composeMode && evt.keyCode == 27) {
      this.toggleComposer()
      evt.preventDefault()

      // we should check for text and fire a warning prompt before exiting & clear the form
      app.router.navigate(app.currentUser.expProfileUrl(), {replace : true})
    }
  },

  toggleComposer : function(){
    this.composeMode = !this.composeMode
    $("body").toggleClass("lock")

    if(!this.composeMode) {
      this.$("#composer").toggleClass("zoom-out")
      setTimeout('this.$("#composer").toggleClass("hidden").toggleClass("zoom-out")', 200)
    } else {
      this.$("#composer").toggleClass("hidden")
    }
    this.$("#composer").toggleClass("zoom-in")
  },

  logOutConfirm : function(evt) {
    if(!confirm("Are you sure you want to log out?"))
      evt.preventDefault();
  },
});
