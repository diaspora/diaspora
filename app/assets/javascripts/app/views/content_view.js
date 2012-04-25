//= require ./stream_object_view
app.views.Content = app.views.StreamObject.extend({

  events: {
    "click .expander": "expandPost"
  },

  presenter : function(){
    return _.extend(this.defaultPresenter(), {
      text : app.helpers.textFormatter(this.model.get("text"), this.model),
      largePhoto : this.largePhoto(),
      smallPhotos : this.smallPhotos()
    });
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


  expandPost: function(evt) {
    var el = $(this.el).find('.collapsible');
    el.removeClass('collapsed').addClass('opened');
    el.animate({'height':el.data('orig-height')}, 550, function() {
      el.css('height','auto');
    });
    $(evt.currentTarget).hide();
  },

  collapseOversized : function() {
    var collHeight = 200
      , elem = this.$(".collapsible")
      , oembed = elem.find(".oembed")
      , addHeight = 0;

    if($.trim(oembed.html()) != "") {
      addHeight = oembed.height();
    }

    // only collapse if height exceeds collHeight+20%
    if( elem.height() > ((collHeight*1.2)+addHeight) && !elem.is(".opened") ) {
      elem.data("orig-height", elem.height() );
      elem
        .height( Math.max(collHeight, addHeight) )
        .addClass("collapsed")
        .append(
        $('<div />')
          .addClass('expander')
          .text( Diaspora.I18n.t("show_more") )
      );
    }
  },

  postRenderTemplate : function(){
    _.defer(_.bind(this.collapseOversized, this))
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

app.views.OEmbed = app.views.Base.extend({
  templateName : "oembed",
  events : {
    "click .oembed .thumb": "showOembedContent"
  },

  presenter:function () {
    return _.extend(this.defaultPresenter(), {
      o_embed_html:this.embedHTML()
    })
  },

  embedHTML:function () {
    if (!this.model.get("o_embed_cache")) {
      return "";
    }
    var data = this.model.get("o_embed_cache").data;
    if (data.type == "photo") {
      return '<img src="' + data.url + '" width="' + data.width + '" height="' + data.height + '" />';
    } else {
      return data.html || ""
    }
  },

  showOembedContent:function () {
    var insertHTML = $(this.embedHTML());
    var paramSeparator = ( /\?/.test(insertHTML.attr("src")) ) ? "&" : "?";
    insertHTML.attr("src", insertHTML.attr("src") + paramSeparator + "autoplay=1");
    this.$el.html(insertHTML);
  },
})