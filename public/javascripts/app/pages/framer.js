app.pages.Framer = app.views.Base.extend({
  templateName : "framer",

  events : {
    "click button.done" : "saveFrame"
  },

  subviews : {
    ".post-view" : "postView"
  },

  initialize : function(){
    this.model = app.frame

    var templateType = "status"

    this.model.authorIsNotCurrentUser = function(){ return false }

    this.postView = new app.views.Post({
      model : this.model,
      className : templateType + " post loaded",
      templateName : "post-viewer/content/" + templateType,
      attributes : {"data-template" : templateType}
    });

    this.postView.feedbackView = new Backbone.View
  },

  saveFrame : function(){
    this.model.save()
  }
})