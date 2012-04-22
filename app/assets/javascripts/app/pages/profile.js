//= require ../views/small_frame

app.pages.Profile = app.views.Base.extend({

  className : "container",

  templateName : "profile",

  subviews : {
    "#canvas" : "canvasView"
  },

  events : {
    "click #edit-mode-toggle" : "toggleEdit"
  },

  editMode : false,

  initialize : function(options) {
    this.model = new app.models.Profile.findByGuid(options.personId)
    this.stream = options && options.stream || new app.models.Stream()
    this.stream.fetch();
    this.model.bind("change", this.render, this) //this should go on profile info view when it gets Extracted

    this.canvasView = new app.views.Canvas({model : this.stream})
  },

  toggleEdit : function(evt) {
    if(evt) { evt.preventDefault() }
    this.editMode = !this.editMode
    this.$el.toggleClass("edit-mode")
  }

});