app.forms.Post = app.views.Base.extend({
  templateName : "post-form",
  className : "post-form",

  subviews : {
    ".new_picture" : "pictureForm"
   },

  initialize : function() {
    this.pictureForm = new app.forms.Picture();
  },

  postRenderTemplate : function() {
    //this.prepAndBindMentions()
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