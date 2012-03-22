app.pages.Framer = app.views.Base.extend({
  templateName : "framer",

  id : "post-content",

  events : {
    "click button.done" : "saveFrame"
  },

  subviews : {
    ".post-view" : "postView",
    ".template-picker" : "templatePicker"
  },

  initialize : function(){
    this.model = app.frame

    this.model.bind("change", this.render, this)
    this.templatePicker = new app.views.TemplatePicker({ model: this.model })
  },

  postView : function(){
    //we might be leaky like cray cray with this

    var templateType = this.model.get("frame_name")

     this._postView = new app.views.Post({
      model : this.model,
      className : templateType + " post loaded",
      templateName : "post-viewer/content/" + templateType,
      attributes : {"data-template" : templateType}
    });

    this._postView.feedbackView = new Backbone.View

    this.model.authorIsNotCurrentUser = function(){ return false }

    return this._postView
  },

  saveFrame : function(){
    this.model.save()
  }
})
