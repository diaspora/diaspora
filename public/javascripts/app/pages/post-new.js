app.pages.PostNew = app.views.Base.extend({
  templateName : "post-new",

  subviews : { "#new-post" : "postForm"},

  initialize : function(){
    this.model = new app.models.StatusMessage()
    this.postForm = new app.views.PostForm({model : this.model})

    this.model.bind("setFromForm", this.saveModel, this)
  },

  saveModel : function(){
    this.model.mungeAndSave();
  }
})
