app.pages.PostNew = app.views.Base.extend({
  templateName : "post-new",

  subviews : { "#new-post" : "postForm"},

  events : {
    "click button.next" : "navigateNext"
  },

  initialize : function(){
    this.model = new app.models.StatusMessage()
    this.postForm = new app.forms.Post({model : this.model})
  },

  navigateNext : function(){
    this.postForm.setModelAttributes()
    app.frame = this.model;
    app.router.navigate("framer", true)
  }
});
