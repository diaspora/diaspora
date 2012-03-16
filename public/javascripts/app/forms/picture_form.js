app.forms.Picture = app.forms.Base.extend({
  templateName : "picture-form",

  events : {
    'ajax:complete .new_photo' : "photoUploaded"
  },

  initialize : function() {
    this.photos = new Backbone.Collection()
    this.photos.bind("add", this.render, this)
  },

  photoUploaded : function(evt, xhr) {
    resp = JSON.parse(xhr.responseText)
    if(resp.success) {
      this.photos.add(new Backbone.Model(resp.data))
    } else {
      alert("Upload failed!  Please try again. " + resp.error);
    }
  },

  postRenderTemplate : function(){
    this.$("input[name=authenticity_token]").val($("meta[name=csrf-token]").attr("content"))
    this.$("input[name=photo_ids]").val(this.photos.pluck("id"))
    this.renderPhotos();
  },

  renderPhotos : function(){
    var photoContainer = this.$(".photos")
    this.photos.each(function(photo){
      var photoView = new app.views.Photo({model : photo}).render().el
      photoContainer.append(photoView)
    })
  }
});