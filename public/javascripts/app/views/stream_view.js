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
  },

  setupEvents : function(){
    this.stream.bind("fetched", this.removeLoader, this)
    this.stream.bind("allPostsLoaded", this.unbindInfScroll, this)
    this.collection.bind("add", this.addPost, this);
  },

  addPost : function(post) {
    var postView = new app.views.Post({ model: post });

    $(this.el)[
      (this.collection.at(0).id == post.id)
        ? "prepend"
        : "append"
    ](postView.render().el);

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
