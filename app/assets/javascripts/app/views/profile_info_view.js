app.views.ProfileInfo = app.views.Base.extend({
  templateName : "profile-info",

  tooltipSelector : "*[rel=tooltip]",

  initialize : function(){
    this.model.bind("change", this.render, this)
  }
});