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
    "input.aspect_ids" : "aspect_ids[]",
    "input.services" : "services[]"
  },

  initialize : function(){
    app.frame = this.model = this.model || new app.models.StatusMessage();
    this.postForm = new app.forms.Post({model : this.model});
    this.composerControls = new app.views.ComposerControls({model : this.model});
  },

  unbind : function(){
    this.model.off()
    this.model.photos.off()
  },

  navigateNext : function(){
    var self = this,
        textArea = this.$("form textarea.text")

    textArea.mentionsInput('val', function(markup){
      textArea.mentionsInput('getMentions', function(mentions){
        var overrides = {
          text : markup,
          mentioned_people : mentions
        }

        self.setModelAttributes(overrides);
        app.router.navigate("framer", true);
      })
    });
  },

  setModelAttributes : function(overrides){
    var form = this.$el;
    this.model.set(_.inject(this.formAttrs, setValueFromField, {}))
    this.model.photos = this.postForm.pictureForm.photos
    this.model.set({"photos": this.model.photos.toJSON() })
    this.model.set(overrides)


    function setValueFromField(memo, attribute, selector){
      if(attribute.slice("-2") === "[]") {
        memo[attribute.slice(0, attribute.length - 2)] = _.pluck(form.find(selector).serializeArray(), "value")
      } else {
        memo[attribute] = form.find(selector).val();
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
    this.aspectsDropdown = new app.views.AspectsDropdown({model : this.model});
    this.servicesSelector = new app.views.ServicesSelector({model : this.model});
  }
})
