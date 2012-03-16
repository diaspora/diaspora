app.forms.Post = app.forms.Base.extend({
  templateName : "post-form",
  formSelector : ".new-post",

  subviews : {
    ".aspect_selector" : "aspectsDropdown",
    ".service_selector" : "servicesSelector",
    ".new_picture" : "pictureForm"
   },

  formAttrs : {
    "textarea#text_with_markup" : "text",
    "input.aspect_ids" : "aspect_ids",
    "input.service:checked" : "services"
  },

  initialize : function() {
    this.aspectsDropdown = new app.views.AspectsDropdown();
    this.servicesSelector = new app.views.ServicesSelector();
    this.pictureForm = new app.forms.Picture();

    this.setupFormEvents();
  },

  setModelAttributes : function(evt){
    if(evt){ evt.preventDefault(); }
    var form = this.$(this.formSelector);

    this.model.set(_.inject(this.formAttrs, setValueFromField, {}))
    //pass collections across
    this.model.photos = this.pictureForm.photos
    this.model.trigger("setFromForm")

    function setValueFromField(memo, attribute, selector){
      var selectors = form.find(selector);
      if(selectors.length > 1) {
        memo[attribute] = _.map(selectors, function(selector){
          return $(selector).val()
        })
      } else {
        memo[attribute] = selectors.val();
      }
      return memo
    }
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