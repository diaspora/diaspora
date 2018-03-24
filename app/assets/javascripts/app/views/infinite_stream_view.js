// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

// Abstract Infinite Scroll View Super Class
//  Requires:
//    a stream model, assigned to this.stream
//    a stream's posts, assigned to this.collection
//    a postClass to be declared
//    a #paginate div in the layout
//    a call to setupInfiniteScroll

app.views.InfScroll = app.views.Base.extend({
  setupInfiniteScroll : function() {
    this.postViews = this.postViews || [];
    this._resetPostFragments();

    this.showLoader();
    this.bind("loadMore", this.fetchAndshowLoader, this);
    this.stream.bind("fetched", this.finishedLoading, this);
    this.stream.bind("allItemsLoaded", this.showNoPostsInfo, this);
    this.stream.bind("allItemsLoaded", this.unbindInfScroll, this);

    this.collection.bind("add", this.addPostView, this);

    var throttledScroll = _.throttle(_.bind(this.infScroll, this), 200);
    $(window).scroll(throttledScroll);
  },

  _resetPostFragments: function() {
    this.appendedPosts  = document.createDocumentFragment();
    this.prependedPosts = document.createDocumentFragment();
  },

  createPostView : function(post){
    var postView = new this.postClass({ model: post, stream: this.stream });
    if (this.collection.at(0).id === post.id) {
      // post is first in collection - insert view at top of the list
      this.postViews.unshift(postView);
    } else {
      this.postViews.push(postView);
    }
    return postView;
  },

  // called for every item inserted in this.collection
  addPostView : function(post) {
    var el = this.createPostView(post).render().el;
    if (this.collection.at(0).id === post.id) {
        this.prependedPosts.insertBefore(el, this.prependedPosts.firstChild);
    } else {
        this.appendedPosts.appendChild(el);
    }
  },

  postRenderTemplate: function() {
    if (this.postViews.length > 0) {
      this.$(".no-posts-info").closest(".stream-element").remove();
    }
  },

  showNoPostsInfo: function() {
    if (this.postViews.length === 0) {
      var noPostsInfo = new app.views.NoPostsInfo();
      this.$el.append(noPostsInfo.render().el);
    }
  },

  unbindInfScroll : function() {
    $(window).unbind("scroll");
  },

  renderTemplate : function(){
    this.renderInitialPosts();
  },

  renderInitialPosts : function(){
    this.$el.empty();
    var els = document.createDocumentFragment();
    this.stream.items.each(_.bind(function(post){
      els.appendChild(this.createPostView(post).render().el);
    }, this));
    this.$el.html(els);
  },

  fetchAndshowLoader : function(){
    if( this.stream.isFetching() ) return false;

    this.stream.fetch();
    this.showLoader();
  },

  showLoader: function(){
    $("#paginate .loader").removeClass("hidden");
  },

  finishedAdding: function() {
    this.$el.prepend(this.prependedPosts);
    this.$el.append(this.appendedPosts);
    this._resetPostFragments();
    this.postRenderTemplate();
  },

  finishedLoading: function() {
    this.finishedAdding();
    this.hideLoader();
  },

  hideLoader: function() {
    $("#paginate .loader").addClass("hidden");
  },

  infScroll : function() {
    var $window = $(window),
        distFromBottom = $(document).height() - $window.height() - $window.scrollTop(),
        lastElOffset = this.$el.children().last().offset(),
        elementDistance = lastElOffset ? lastElOffset.top - $window.scrollTop() - 500 : 1;

    if(elementDistance <= 0 || distFromBottom < 500) {
      this.trigger("loadMore");
    }
  }
});
// @license-end
