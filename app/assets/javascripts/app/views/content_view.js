// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Content = app.views.Base.extend({
  events: {
    "click .expander": "expandPost",
    "click .collapse_post": "collapsePost"
  },

  tooltipSelector: ".collapse_post",

  presenter : function(){
    return _.extend(this.defaultPresenter(), {
      text : app.helpers.textFormatter(this.model.get("text"), this.model),
      largePhoto : this.largePhoto(),
      smallPhotos : this.smallPhotos(),
      location: this.location()
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
    photos.splice(0, 1); // remove first photo as it is already shown as largePhoto
    return photos;
  },


  expandPost: function(evt) {
    var el = $(this.el).find('.collapsible')
      , collapsePostEl = $(this.el).find('.collapse_post');
    el.removeClass('collapsed').addClass('opened');
    el.animate({'height':el.data('orig-height')}, 550, function() {
      el.css('height','auto');
    });
    $(evt.currentTarget).remove();
    collapsePostEl.show();
  },

  location: function(){
    var address = this.model.get('address')? this.model.get('address') : '';
    return address;
  },

  collapsePost : function() {
    var elem = this.$(".collapsible");
    elem.removeClass("opened");

    // scroll to top of the post and collapse
    var distanceToTop = this.$el.parents().filter('.stream_element').offset().top;
    if(distanceToTop < $("html, body").scrollTop()) { // scroll upwards only
      $("html, body").animate(
        {'scrollTop': (distanceToTop - this.navigationBarHeight - 10)},
        550,
        _.bind(function(){
          this.collapseOversized();
        }, this)
      );
    } else {
      this.collapseOversized();
    }
  },

  collapseOversized : function() {
    var collHeight = 200
      , elem = this.$(".collapsible")
      , oembed = elem.find(".oembed")
      , opengraph = elem.find(".opengraph")
      , poll = elem.find(".poll")
      , collapsePostEl = this.$('.collapse_post')
      , addHeight = 0;
    if($.trim(oembed.html()) != "") {
      addHeight += oembed.height();
    }
    if($.trim(opengraph.html()) != "") {
      addHeight += opengraph.height();
    }
    if($.trim(poll.html()) != "") {
      addHeight += poll.height();
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
      collapsePostEl.hide();
    }
  },

  collapseControlPositionUpdater: function() {
    var box = this.el.getBoundingClientRect();
    var collapseControl = this.$el.find('.collapse_post');

    // Top of the post is above viewport-top and bottom is still visible
    // --> make the collapse control sticky
    if(box.top < this.navigationBarHeight
        && box.top + box.height - collapseControl.outerHeight(true) > this.navigationBarHeight) {
      var posLeft = box.left + box.width - collapseControl.outerWidth(true);
      collapseControl.addClass('collapseFixed').css('left', posLeft);
    } else {
      collapseControl.removeClass('collapseFixed').css('left', 'auto');
    }
  },

  postRenderTemplate : function(){
    _.defer(_.bind(this.collapseOversized, this));

    _.defer(_.bind(function() {
      this.navigationBarHeight = $('header').outerHeight();

      var throttledScroll = _.throttle(_.bind(
        this.collapseControlPositionUpdater, this), 200
      );
      $(window).scroll(throttledScroll);
    }, this));
  }
});

app.views.StatusMessage = app.views.Content.extend({
  templateName : "status-message"
});

app.views.ExpandedStatusMessage = app.views.StatusMessage.extend({
  postRenderTemplate : function(){
  }
});

app.views.Reshare = app.views.Content.extend({
  templateName : "reshare"
});

app.views.OEmbed = app.views.Base.extend({
  templateName : "oembed",
  events : {
    "click .thumb": "showOembedContent"
  },

  presenter:function () {
    o_embed_cache = this.model.get("o_embed_cache")
    if(o_embed_cache) {
      typemodel = { rich: false, photo: false, video: false, link: false }
      typemodel[o_embed_cache.data.type] = true
      o_embed_cache.data.types = typemodel
    }
    return _.extend(this.defaultPresenter(), {
      o_embed_html : app.helpers.oEmbed.html(o_embed_cache)
    })
  },

  showOembedContent : function (evt) {
    if( $(evt.target).is('a') ) return;
    var insertHTML = $(app.helpers.oEmbed.html(this.model.get("o_embed_cache")));
    var paramSeparator = ( /\?/.test(insertHTML.attr("src")) ) ? "&" : "?";
    insertHTML.attr("src", insertHTML.attr("src") + paramSeparator + "autoplay=1&wmode=opaque");
    this.$el.html(insertHTML);
  }
});

app.views.OpenGraph = app.views.Base.extend({
  templateName : "opengraph"
});
// @license-end

