app.views.Stream = Backbone.View.extend({
  events: {
    "click #paginate": "render"
  },

  initialize: function() {
    this.collection = this.collection || new app.collections.Stream;
    this.collection.bind("add", this.addPost, this);

    this.publisher = new app.views.Publisher({collection : this.collection});

    // inf scroll
    // we're using this._loading to keep track of backbone's collection
    //   fetching state... is there a better way to do this?
    var throttledScroll = _.throttle($.proxy(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);

    // lightbox delegation
    this.lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
    $(this.el).delegate("a.stream-photo-link", "click", this.lightbox.lightboxImageClicked);

    return this;
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

  isLoading : function(){
    return this._loading && !this._loading.isResolved();
  },

  allContentLoaded : false,

  addPost : function(post) {
    var postView = new app.views.Post({ model: post });

    $(this.el)[
      (this.collection.at(0).id == post.id)
        ? "prepend"
        : "append"
    ](postView.render().el);

    return this;
  },

  collectionFetched: function(collection, response) {
    this.$("#paginate").remove();

    if(!collection.parse(response).length || collection.parse(response).length == 0) {
      this.allContentLoaded = true;
      $(window).unbind('scroll')
      return
    }

    $(this.el).append($("<a>", {
      href: this.collection.url(),
      id: "paginate"
    }).text('Load more posts'));
  },

  render : function(evt) {
    if(evt) { evt.preventDefault(); }

    var self = this;
    self.addLoader();

    this._loading = self.collection.fetch({
      add: true,
      success: $.proxy(this.collectionFetched, self)
    });

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
  }
});
