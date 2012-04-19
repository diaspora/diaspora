//= require ../views/small_frame

app.pages.Profile = app.views.Base.extend({

  templateName : "profile",

  subviews : {
    "#canvas" : "canvasView"
  },

  initialize : function(options) {
    this.model = new app.models.Profile.findByGuid(options.personId)
    this.stream = options && options.stream || new app.models.Stream()
    this.stream.fetch();
    this.model.bind("change", this.render, this) //this should go on profile info view when it gets Extracted

    this.canvasView = new app.views.Canvas({model : this.stream})
  }
});