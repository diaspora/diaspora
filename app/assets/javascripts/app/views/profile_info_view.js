app.views.ProfileInfo = app.views.Base.extend({
  templateName : "profile-info",

  initialize : function(){
    console.log(this.model)
    this.model.bind("change", this.render, this) //this should go on profile info view when it gets Extracted
  }
})