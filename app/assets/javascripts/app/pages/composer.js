app.pages.Composer = app.views.Base.extend({
  templateName : "flow",

  subviews : {
    ".flow-content" : "postForm",
    ".flow-controls .controls" : "composerControls"
  },

  events : {
    "click button.next" : "navigateNext"
  },

  formAttrs : {
    "textarea#text_with_markup" : "text",
    "input.aspect_ids" : "aspect_ids",
    "input.service:checked" : "services"
  },


  initialize : function(){
    app.frame = this.model = new app.models.StatusMessage();
    this.postForm = new app.forms.Post({model : this.model});
    this.composerControls = new app.views.ComposerControls({model : this.model});
  },

  navigateNext : function(){
    this.$("form textarea.text").mentionsInput('val',
      _.bind(function(markup){
        $('#text_with_markup').val(markup);
        this.setModelAttributes();
        app.router.navigate("framer", true);
      }, this)
    );
  },

  setModelAttributes : function(evt){
    if(evt){ evt.preventDefault(); }

    var form = this.$el;

    this.model.set(_.inject(this.formAttrs, setValueFromField, {}))
    this.model.photos = this.postForm.pictureForm.photos
    this.model.set({"photos": this.model.photos.toJSON() })

    function setValueFromField(memo, attribute, selector){
      var selectors = form.find(selector);
      if(selectors.length > 1) {
        memo[attribute] = _.map(selectors, function(selector){
          return this.$(selector).val()
        })
      } else {
        memo[attribute] = selectors.val();
      }
      return memo
    }
  }
});

app.views.ComposerControls = app.views.Base.extend({
  templateName : 'composer-controls',

  subviews : {
    ".aspect-selector" : "aspectsDropdown",
    ".service-selector" : "servicesSelector"
  },

  initialize : function() {
    this.aspectsDropdown = new app.views.AspectsDropdown();
    this.servicesSelector = new app.views.ServicesSelector();
  }
})
