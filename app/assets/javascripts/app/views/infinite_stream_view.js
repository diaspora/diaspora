// Abstract Infinite Scroll View Super Class
//  Requires:
//    a stream model, assigned to this.stream
//    a stream's posts, assigned to this.collection
//    a postClass to be declared
//    a #paginate div in the layout
//    a call to setupInfiniteScroll

app.views.InfScroll = app.views.Base.extend({
  setupInfiniteScroll : function() {
    this.postViews = this.postViews || []

    this.bind("loadMore", this.fetchAndshowLoader, this)
    this.stream.bind("fetched", this.hideLoader, this)
    this.stream.bind("allItemsLoaded", this.unbindInfScroll, this)

    this.collection.bind("add", this.addPostView, this);

    var throttledScroll = _.throttle(_.bind(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);
  },

  postRenderTemplate : function() {
    if(this.stream.isFetching()) { this.showLoader() }
  },

  createPostView : function(post){
    var postView = new this.postClass({ model: post, stream: this.stream });
    this.postViews.push(postView)
    return postView
  },

  addPostView : function(post) {
    var placeInStream = (this.collection.at(0).id == post.id) ? "prepend" : "append";
    this.$el[placeInStream](this.createPostView(post).render().el);
  },

  unbindInfScroll : function() {
    $(window).unbind("scroll");
  },

  renderTemplate : function(){
    this.renderInitialPosts()
  },

  renderInitialPosts : function(){
    this.$el.empty()
    this.stream.items.each(_.bind(function(post){
      this.$el.append(this.createPostView(post).render().el);
    }, this))
  },

  fetchAndshowLoader : function(){
    if(this.stream.isFetching()) { return false }
    this.stream.fetch()
    this.showLoader()
  },

  showLoader: function(){
    $("#paginate .loader").removeClass("hidden")
  },

  hideLoader: function() {
    $("#paginate .loader").addClass("hidden")
  },

  infScroll : function() {
    var $window = $(window)
      , distFromTop = $window.height() + $window.scrollTop()
      , distFromBottom = $(document).height() - distFromTop
      , bufferPx = 500;

    if(distFromBottom < bufferPx) {
      this.trigger("loadMore")
    }
  }
});
