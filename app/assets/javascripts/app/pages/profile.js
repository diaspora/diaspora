//= require ../views/small_frame
//= require ../views/profile_info_view

app.pages.Profile = app.views.Base.extend({
  className : "container",

  templateName : "profile",

  subviews : {
    "#profile-info" : "profileInfo",
    "#canvas" : "canvasView"
  },

  events : {
    "click #edit-mode-toggle" : "toggleEdit"
  },

  editMode : false,

  presenter : function(){
    var bio =  this.model.get("bio") || ''
    return _.extend(this.defaultPresenter(),
      {text : this.model && app.helpers.textFormatter(bio, this.model),
       isOwnProfile : true })
  },

  initialize : function(options) {
    this.model = new app.models.Profile.findByGuid(options.personId)
    this.stream = options && options.stream || new app.models.Stream()
    this.stream.preloadOrFetch();

    this.canvasView = new app.views.Canvas({ model : this.stream })
    this.profileInfo = new app.views.ProfileInfo({ model : this.model })
  },

  toggleEdit : function(evt) {
    if(evt) { evt.preventDefault() }
    this.editMode = !this.editMode
    this.$el.toggleClass("edit-mode")
  },

  isOwnProfile : function() {
    // this is all tested, but does not work.  there is something weird going here :(
    // i'm going to return true in the presenter for now until this is resolved.

    return(app.currentUser.get("diaspora_id") == this.model.get("diaspora_id"))
  }
});