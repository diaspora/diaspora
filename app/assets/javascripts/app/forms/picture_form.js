app.forms.PictureBase = app.views.Base.extend({
  events : {
    'ajax:complete .new_photo' : "photoUploaded",
    "change input[name='photo[user_file]']" : "submitForm"
  },

  onSubmit : $.noop,
  uploadSuccess : $.noop,

  postRenderTemplate : function(){
    this.$("input[name=authenticity_token]").val($("meta[name=csrf-token]").attr("content"))
  },

  submitForm : function (){
    this.$("form").submit();
    this.onSubmit();
  },

  photoUploaded : function(evt, xhr) {
    resp = JSON.parse(xhr.responseText)
    if(resp.success) {
      this.uploadSuccess(resp)
    } else {
      alert("Upload failed!  Please try again. " + resp.error);
    }
  }
});

/* multi photo uploader */
app.forms.Picture = app.forms.PictureBase.extend({
  templateName : "picture-form",

  initialize : function() {
    this.photos = this.model.photos || new Backbone.Collection()
    this.photos.bind("add", this.render, this)
  },

  postRenderTemplate : function(){
    this.$("input[name=authenticity_token]").val($("meta[name=csrf-token]").attr("content"))
    this.$("input[name=photo_ids]").val(this.photos.pluck("id"))
    this.renderPhotos();
  },

  onSubmit : function (){
    this.$(".photos").append($('<span class="loader" style="margin-left: 80px;"></span>'))
  },

  uploadSuccess : function(resp) {
    this.photos.add(new Backbone.Model(resp.data))
  },

  renderPhotos : function(){
    var photoContainer = this.$(".photos")
    this.photos.each(function(photo){
      var photoView = new app.views.Photo({model : photo}).render().el
      photoContainer.append(photoView)
    })
  }
});
