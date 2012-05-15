//= require ../views/small_frame
//= require ../views/profile_info_view

app.pages.Profile = app.views.Base.extend({
  templateName : "profile",
  id : "profile",

  subviews : {
    "#profile-info" : "profileInfo",
    "#canvas" : "canvasView",
    "#wallpaper-upload" : "wallpaperForm"
  },

  events : {
    "click #edit-mode-toggle" : "toggleEdit",
    "click #logout-button" : "logOutConfirm"
  },

  tooltipSelector : "*[rel=tooltip]",

  personGUID : null,
  editMode : false,

  initialize : function(options) {
    this.personGUID = options.personId

    this.model = this.model || app.models.Profile.preloadOrFetch(this.personGUID)
    this.stream = options && options.stream || new app.models.Stream()

    this.stream.preloadOrFetch().done(_.bind(this.pulsateNewPostControl, this));
    this.stream.items.bind("remove", this.pulsateNewPostControl, this)

    /* this needs to be fixed... used to be bound by this.model change event.
    *  will most likely result in spontaneous results :(
    *
    *  note: defer to make sure the call stack is emptied before calling this, buying us a little more time */
    _.defer(_.bind(this.setPageTitleAndBackground, this))

    this.canvasView = new app.views.Canvas({ model : this.stream })
    this.wallpaperForm = new app.forms.Wallpaper()
    this.profileInfo = new app.views.ProfileInfo({ model : this.model })
  },

  presenter : function(){
    var bio =  this.model.get("bio") || ''

    return _.extend(this.defaultPresenter(),
      {text : this.model && app.helpers.textFormatter(bio, this.model),
        showFollowButton : this.showFollowButton()
      })
  },

  pulsateNewPostControl : function() {
    this.$("#composer-button")[
      this.stream.items.length == 0
        ? 'addClass'
        : 'removeClass'
      ]("pulse")
  },

  setPageTitleAndBackground : function() {
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

  logOutConfirm : function(evt) {
    if(!confirm("Are you sure you want to log out?"))
      evt.preventDefault();
  },

  followingEnabled : function() {
    var user = app.currentUser
    return user.get("following_count") != 0 && user.get("diaspora_id") !== undefined
  },

  showFollowButton : function() {
    return this.followingEnabled() && !this.model.get("is_own_profile")
  }
});
