app.forms.PictureBase = app.views.Base.extend({
  events : {
    'ajax:complete .new_photo' : "photoUploaded",
    "change input[name='photo[user_file]']" : "submitForm"
  },

  photoUploaded : $.noop,

  postRenderTemplate : function(){
    this.$("input[name=authenticity_token]").val($("meta[name=csrf-token]").attr("content"))
  },

  submitForm : function (){
    this.$("form").submit();
  }
});

/* multi photo uploader */
app.forms.Picture = app.forms.PictureBase.extend({
  templateName : "picture-form",

  initialize : function() {
    this.photos = new Backbone.Collection()
    this.photos.bind("add", this.render, this)
  },

  postRenderTemplate : function(){
    this.$("input[name=authenticity_token]").val($("meta[name=csrf-token]").attr("content"))
    this.$("input[name=photo_ids]").val(this.photos.pluck("id"))
    this.renderPhotos();
  },

  submitForm : function (){
    this.$("form").submit();
    this.$(".photos").append($('<span class="loader" style="margin-left: 80px;"></span>'))
  },

  photoUploaded : function(evt, xhr) {
    resp = JSON.parse(xhr.responseText)
    if(resp.success) {
      this.photos.add(new Backbone.Model(resp.data))
    } else {
      alert("Upload failed!  Please try again. " + resp.error);
    }
  },

  renderPhotos : function(){
    var photoContainer = this.$(".photos")
    this.photos.each(function(photo){
      var photoView = new app.views.Photo({model : photo}).render().el
      photoContainer.append(photoView)
    })
  }
});

/* wallpaper uploader */
app.forms.Wallpaper = app.forms.PictureBase.extend({
  templateName : "wallpaper-form",

  photoUploaded : function(evt, xhr) {
    resp = JSON.parse(xhr.responseText)
    if(resp.success) {
      $("#profile").css("background-image", "url(" + resp.data.wallpaper + ")")
    } else {
      alert("Upload failed!  Please try again. " + resp.error);
    }
  }
});