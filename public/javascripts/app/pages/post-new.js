app.pages.PostNew = app.views.Base.extend({
  templateName : "post-new",

  subviews : { "#new-post" : "postForm"},

  initialize : function(){
    console.log("In the page")

    this.model = new app.models.Post()
    this.postForm = new app.views.PostForm({model : this.model})
  }
})
