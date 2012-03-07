app.forms.Post = app.forms.Base.extend({
  templateName : "post-form",

  subviews : {
    ".aspect_selector" : "aspectsDropdown"
  },

  formAttrs : {
    ".text" : "text",
//    ".aspect_ids" : "aspect_ids"
  },

  initialize : function(){
    this.aspectsDropdown = new app.views.AspectsDropdown()
  }
});