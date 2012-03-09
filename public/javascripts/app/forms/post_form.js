app.forms.Post = app.forms.Base.extend({
  templateName : "post-form",

  subviews : {
    ".aspect_selector" : "aspectsDropdown",
    ".service_selector" : "servicesSelector"
  },

  formAttrs : {
    "textarea#text_with_markup" : "text",
    "input.aspect_ids" : "aspect_ids",
    'input.service:checked' : 'services'
  },

  initialize : function() {
    this.aspectsDropdown = new app.views.AspectsDropdown();
    this.servicesSelector = new app.views.ServicesSelector();
  },

  postRenderTemplate : function() {
    this.prepAndBindMentions()
  },

  prepAndBindMentions : function(){
    Mentions.initialize(this.$("textarea.text"));
    Mentions.fetchContacts();

    this.$("textarea.text").bind("textchange", $.proxy(this.updateTextWithMarkup, this))
  },

  updateTextWithMarkup : function() {
    this.$("form textarea.text").mentionsInput('val', function(markup){
      $('#text_with_markup').val(markup);
    });
  }
});