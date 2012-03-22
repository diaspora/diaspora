app.views.Stream = Backbone.View.extend({
  
  events: {
    "click #paginate": "render"
  },

  initialize: function(options) {
    this.stream = this.model
    this.collection = this.model.posts

    this.setupEvents()
    this.setupInfiniteScroll()
    this.setupLightbox()
    this.postViews = []
  },

  setupEvents : function(){
    this.stream.bind("fetched", this.removeLoader, this)
    this.stream.bind("fetched", this.postRender, this)
    this.stream.bind("allPostsLoaded", this.unbindInfScroll, this)
    this.collection.bind("add", this.addPost, this);
    if(window.app.user()) {
      app.user().bind("nsfwChanged", function() {
          _.map(this.postViews, function(view){ view.render() })
        }, this)
    }
  },

  addPost : function(post) {
    var postView = new app.views.Post({ model: post });

    $(this.el)[
      (this.collection.at(0).id == post.id)
        ? "prepend"
        : "append"
    ](postView.render().el);

    this.postViews.push(postView)
    return this;
  },

  unbindInfScroll : function() {
    $(window).unbind("scroll");
  },

  render : function(evt) {
    if(evt) { evt.preventDefault(); }

    // fetch more posts from the stream model
    if(this.stream.fetch()) {
      this.appendLoader()
    };

    return this;
  },

  postRender : function() {
    // collapse long posts
    var collHeight = 190,
        collElem = $(this.el).find(".collapsible");

    _.each(collElem, function(elem) {
      var elem = $(elem),
          oembed = elem.find(".oembed"),
          addHeight = 0;

      if( $.trim(oembed.html()) != "" ) {
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
    });
  },
  
  appendLoader: function(){
    $("#paginate").html($("<img>", {
      src : "/images/static-loader.png",
      "class" : "loader"
    }));
  },

  removeLoader: function() {
    $("#paginate").empty();
  },

  setupLightbox : function(){
    this.lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
    $(this.el).delegate("a.stream-photo-link", "click", this.lightbox.lightboxImageClicked);
  },

  setupInfiniteScroll : function() {
    var throttledScroll = _.throttle($.proxy(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);
  },

  infScroll : function() {
    var $window = $(window);
    var distFromTop = $window.height() + $window.scrollTop();
    var distFromBottom = $(document).height() - distFromTop;
    var bufferPx = 500;

    if(distFromBottom < bufferPx) {
      this.render();
    }

    return this;
  },
});
