//= require ./stream_object_view
app.views.Content = app.views.StreamObject.extend({

  events: {
    "click .oembed .thumb": "showOembedContent",
    "click .expander": "expandPost"
  },

  presenter : function(){
    return _.extend(this.defaultPresenter(), {
      text : app.helpers.textFormatter(this.model.get("text"), this.model),
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
    var insertHTML = $( this.embedHTML() );
    var paramSeparator = ( /\?/.test(insertHTML.attr("src")) ) ? "&" : "?";
    insertHTML.attr("src", insertHTML.attr("src") + paramSeparator + "autoplay=1");
    oembed.html( insertHTML );
  },

  expandPost: function(evt) {
    var el = $(this.el).find('.collapsible');
    el.removeClass('collapsed').addClass('opened');
    el.animate({'height':el.data('orig-height')}, 550, function() {
      el.css('height','auto');
    });
    $(evt.currentTarget).hide();
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

