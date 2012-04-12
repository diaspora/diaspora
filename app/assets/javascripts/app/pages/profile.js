app.pages.Profile = app.views.Base.extend({

  templateName : "profile",

  subviews : {
    "#canvas" : "canvasView"
  },

  initialize : function() {
    this.initViews()
  },

  initViews : function() {
    this.canvasView = new app.views.Canvas()
  }
});