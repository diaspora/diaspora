app.pages.Composer = app.views.Base.extend({
  templateName : "flow",

  subviews : {
    ".flow-content" : "postForm",
    ".flow-controls .controls" : "composerControls"
  },

  events : {
    "click .next" : "navigateNext"
  },

  formAttrs : {
    "textarea#text_with_markup" : "text"
  },

  initialize : function(){
    app.frame = this.model = this.model || new app.models.StatusMessage();
    this.postForm = new app.forms.Post({model : this.model});
    this.composerControls = new app.views.ComposerControls({model : this.model});
  },

  unbind : function(){
    this.model.off()
    if(this.model.photos) {
      this.model.photos.off()
    }
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
    this.setFormAttrs()
    this.model.photos = this.postForm.pictureForm.photos
    this.model.set({"photos": this.model.photos.toJSON() })
    this.model.set(overrides)
  }
});

app.views.ComposerControls = app.views.Base.extend({
  templateName : 'composer-controls'
})
