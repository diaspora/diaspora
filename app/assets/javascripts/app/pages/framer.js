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
    this.model.authorIsCurrentUser = function(){ return true }

    this.model.bind("change", this.render, this)
    this.model.bind("sync", this.navigateToShow, this)
    this.templatePicker = new app.views.TemplatePicker({ model: this.model })
  },

  postView : function(){
    return app.views.Post.showFactory(this.model)
  },

  navigateToShow : function(){
    app.router.navigate(this.model.url(), {trigger: true, replace: true})
  },

  saveFrame : function(){
    this.model.save()
  }
})
