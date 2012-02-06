app.views.Content = app.views.StreamObject.extend({
  presenter : function(){
    var model = this.model
    return _.extend(this.defaultPresenter(), {
      text : app.helpers.textFormatter(model),
      o_embed_html : embedHTML(model),
      largePhoto : this.largePhoto(),
      smallPhotos : this.smallPhotos()
    })

    function embedHTML(model){
      if(!model.get("o_embed_cache")) { return ""; }
      var data = model.get("o_embed_cache").data;
      if(data.type == "photo") {
        return '<img src="'+data.url+'" width="'+data.width+'" height="'+data.height+'" />';
      } else {
        return data.html || ""
      }
    }
  },

  largePhoto : function() {
    var photos = this.model.get("photos")
    if(!photos || photos.length == 0) { return }
    return photos[0]
  },

  smallPhotos : function() {
    var photos = this.model.get("photos")
    if(!photos || photos.length < 2) { return }
    return photos.slice(1,8)
  }
})

app.views.StatusMessage = app.views.Content.extend({
  templateName : "status-message"
});

app.views.Reshare = app.views.Content.extend({
  legacyTemplate : true,
  template_name : "#reshare-template"
});

app.views.ActivityStreams__Photo = app.views.Content.extend({
  legacyTemplate : false,
  templateName : "activity-streams-photo"
});

