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

  personGUID : null,
  editMode : false,

  presenter : function(){
    var bio =  this.model.get("bio") || ''
    return _.extend(this.defaultPresenter(),
      {text : this.model && app.helpers.textFormatter(bio, this.model),
       isOwnProfile : this.isOwnProfile() })
  },

  initialize : function(options) {
    this.personGUID = options.personId

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
    return(app.currentUser.get("guid") == this.personGUID)
  }
});