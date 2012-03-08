app.forms.Post = app.forms.Base.extend({
  templateName : "post-form",

  subviews : {
    ".aspect_selector" : "aspectsDropdown"
  },

  formAttrs : {
    "textarea.text" : "text",
    "input.aspect_ids" : "aspect_ids"
  },

  initialize : function(){
    this.aspectsDropdown = new app.views.AspectsDropdown()
  }
});