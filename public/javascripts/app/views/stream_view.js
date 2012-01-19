app.views.Stream = Backbone.View.extend({
  events: {
    "click #paginate": "render"
  },

  initialize: function(options) {
    this.stream = app.stream || new app.models.Stream()
    this.collection = this.stream.posts
    this.publisher = new app.views.Publisher({collection : this.collection});

    this.stream.bind("fetched", this.collectionFetched, this)
    this.collection.bind("add", this.addPost, this);
    this.setupInfiniteScroll()
    this.setupLightbox()
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

  isLoading : function(){
    return this._loading && !this._loading.isResolved();
  },

  allContentLoaded : false,


  collectionFetched: function(collection, response) {
    this.removeLoader()
    if(!collection.parse(response).length || collection.parse(response).length == 0) {
      this.allContentLoaded = true;
      $(window).unbind('scroll')
      return
    }

    $(this.el).append($("<a>", {
      href: this.stream.url(),
      id: "paginate"
    }).text('Load more posts'));
  },

  render : function(evt) {
    if(evt) { evt.preventDefault(); }

    this.addLoader();
    this._loading = this.stream.fetch();

    return this;
  },

  addLoader: function(){
    if(this.$("#paginate").length == 0) {
      $(this.el).append($("<div>", {
        "id" : "paginate"
      }));
    }

    this.$("#paginate").html($("<img>", {
      src : "/images/static-loader.png",
      "class" : "loader"
    }));
  },

  removeLoader : function(){
    this.$("#paginate").remove();
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
    if(this.allContentLoaded || this.isLoading()) { return }

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
