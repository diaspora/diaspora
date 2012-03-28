app.views.PhotoViewer = app.views.Base.extend({
  templateName : "photo-viewer",

  presenter : function(){
    return { photos : this.model.get("photos") } //json array of attributes, not backbone models, yet.
  }
});