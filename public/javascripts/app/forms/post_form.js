app.forms.Post = app.forms.Base.extend({
  templateName : "post-form",

  subviews : {
    ".aspect_selector" : "aspectsDropdown",
    ".service_selector" : "servicesSelector"
  },

  formAttrs : {
    "textarea.text" : "text",
    "input.aspect_ids" : "aspect_ids",
    'input.service:checked' : 'services'
  },

  initialize : function(){
    this.aspectsDropdown = new app.views.AspectsDropdown();
    this.servicesSelector = new app.views.ServicesSelector();
  }
});