app.forms.Picture = app.forms.Base.extend({
  templateName : "picture-form",

  events : {
    'ajax:complete .new_photo' : "photoUploaded"
  },

  postRenderTemplate : function(){
    this.$("input[name=authenticity_token]").val($("meta[name=csrf-token]").attr("content"))
  },

  photoUploaded : function(evt, xhr) {
    resp = JSON.parse(xhr.responseText)
    if(resp.success) {
      console.log(new Backbone.Model(resp.data.photo));
    } else {
      console.log(resp.error);
    };
  }
})