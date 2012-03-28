app.views.Post.Day = app.views.Post.extend({
  templateName : "day",
  className : "day post loaded",

  subviews : { "section.photo_viewer" : "photoViewer" },

  photoViewer : function(){
    return new app.views.PhotoViewer({ model : this.model })
  },

  postRenderTemplate : function(){
    if(this.model.get("text").length < 140){
      this.$('section.text').addClass('headline');
    }
  }
});