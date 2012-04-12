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
    Mentions.initialize(this.$("textarea.text"));
    Mentions.fetchContacts(); //mentions should use app.currentUser
  }
});