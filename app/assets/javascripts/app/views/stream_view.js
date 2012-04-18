app.views.Stream = Backbone.View.extend({
  initialize: function(options) {
    this.stream = this.model
    this.collection = this.model.items

    this.setupEvents()
    this.setupInfiniteScroll()
    this.setupLightbox()
    this.postViews = []
  },

  setupEvents : function(){
    this.stream.bind("fetched", this.removeLoader, this)
    this.stream.bind("allItemsLoaded", this.unbindInfScroll, this)
    this.collection.bind("add", this.addPost, this);

    app.currentUser.bind("nsfwChanged", reRenderPostViews, this)
    function reRenderPostViews() {
      _.map(this.postViews, function(view){ view.render() })
    }
  },

  addPost : function(post) {
    var postView = new app.views.StreamPost({ model: post })
      , placeInStream = (this.collection.at(0).id == post.id) ? "prepend" : "append";

    this.$el[placeInStream](postView.render().el);
    this.postViews.push(postView)
  },

  unbindInfScroll : function() {
    $(window).unbind("scroll");
  },

  render : function() {
    if(this.stream.isFetching()) { this.appendLoader() }
    return this;
  },

  fetchAndAppendLoader : function(){
    if(this.stream.isFetching()) { return false }
    this.stream.fetch()
    this.appendLoader()
  },

  appendLoader: function(){
    $("#paginate .loader").removeClass("hidden")
  },

  removeLoader: function() {
    $("#paginate .loader").addClass("hidden")
  },

  setupLightbox : function(){
    this.lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
    this.$el.delegate("a.stream-photo-link", "click", this.lightbox.lightboxImageClicked);
  },

  setupInfiniteScroll : function() {
    var throttledScroll = _.throttle(_.bind(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);
  },

  infScroll : function() {
    var $window = $(window)
      , distFromTop = $window.height() + $window.scrollTop()
      , distFromBottom = $(document).height() - distFromTop
      , bufferPx = 500;

    if(distFromBottom < bufferPx) {
      this.fetchAndAppendLoader()
    }
  }
});
