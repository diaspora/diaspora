app.views.Content = app.views.StreamObject.extend({

  events: {
    "click .oembed .thumb": "showOembedContent"
  },
  
  presenter : function(){
    return _.extend(this.defaultPresenter(), {
      text : app.helpers.textFormatter(this.model),
      o_embed_html : this.embedHTML(),
      largePhoto : this.largePhoto(),
      smallPhotos : this.smallPhotos()
    });
  },

  embedHTML: function(){
    if(!this.model.get("o_embed_cache")) { return ""; }
    var data = this.model.get("o_embed_cache").data;
    if(data.type == "photo") {
      return '<img src="'+data.url+'" width="'+data.width+'" height="'+data.height+'" />';
    } else {
      return data.html || ""
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
  },

  showOembedContent: function() {
    var oembed = $(this.el).find(".oembed");
    var embedHTML = $( this.embedHTML() );
    var paramSeparator = ( /\\?/.test(embedHTML.attr("href")) ) ? "&" : "?";
    embedHTML.attr("src", embedHTML.attr("src") + paramSeparator + "autoplay=1");
    oembed.html( embedHTML );
  }
});

app.views.StatusMessage = app.views.Content.extend({
  templateName : "status-message"
});

app.views.Reshare = app.views.Content.extend({
  templateName : "reshare"
});

app.views.ActivityStreams__Photo = app.views.Content.extend({
  templateName : "activity-streams-photo"
});

