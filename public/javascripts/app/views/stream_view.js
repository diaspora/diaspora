app.views.Stream = Backbone.View.extend({
  events: {
    "click #paginate": "render"
  },

  initialize: function() {
    this.collection = this.collection || new app.collections.Stream;
    this.collection.bind("add", this.appendPost, this);

    this.publisher = new app.views.Publisher({collection : this.collection});

    // inf scroll
    // we're using this._loading to keep track of backbone's collection
    //   fetching state... is there a better way to do this?
    var throttledScroll = _.throttle($.proxy(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);

    return this;
  },

  infScroll : function(options) {
    var $window = $(window);
    var distFromTop = $window.height() + $window.scrollTop();
    var distFromBottom = $(document).height() - distFromTop;
    var bufferPx = 300;

    if(distFromBottom < bufferPx && !this._loading) {
      this.render();
    }
  },

  prependPost : function(post) {
    var postView = new app.views.Post({ model: post });
    $(this.el).prepend(postView.render().el);

    return this;
  },

  appendPost: function(post) {
    var postView = new app.views.Post({ model: post });
    $(this.el).append(postView.render().el);

    return this;
  },

  collectionFetched: function() {
    this.$("#paginate").remove();
    $(this.el).append($("<a>", {
      href: this.collection.url(),
      id: "paginate"
    }).text('Load more posts'));

    this._loading = false;
  },

  render : function(evt) {
    if(evt) { evt.preventDefault(); }

    var self = this;
    self.addLoader();

    this._loading = true;

    self.collection.fetch({
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
