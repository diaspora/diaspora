app.pages.Stream = app.views.Base.extend({
  templateName : "stream",

  events : {
    'activate .stream-frame-wrapper' : 'triggerInteractionLoad'
  },

  subviews : {
    "#stream-content" : "streamView",
    "#stream-interactions" : "interactionsView"
  },

  initialize : function(){
    this.stream = this.model = new app.models.Stream()
    this.stream.preloadOrFetch()

    this.streamView = new app.pages.Stream.InfiniteScrollView({ model : this.stream })
    this.interactionsView = new app.views.StreamInteractions()

    this.streamView.on('loadMore', this.updateUrlState, this);
    this.stream.on("fetched", this.refreshScrollSpy, this)
    this.stream.on("frame:interacted", this.selectFrame, this)
  },

  selectFrame : function(post){
    if(this.selectedPost == post) { return }
    this.selectedPost = post
    
    this.$(".stream-frame-wrapper").removeClass("selected-frame")
    this.$(".stream-frame-wrapper[data-id=" + this.selectedPost.id +"]").addClass("selected-frame")
    this.interactionsView.setInteractions(this.selectedPost)
  },

  updateUrlState : function(){
    var post = this.stream.items.last();
    if(post){
      this.navigateToPost(post)
    }
  },

  navigateToPost : function(post){
    app.router.navigate(location.pathname + "?max_time=" + post.createdAt(), {replace: true})
  },

  triggerInteractionLoad : function(evt){
    this._throttledInteractions = this._throttledInteractions || _.bind(_.throttle(function(id){
      this.selectFrame(this.stream.items.get(id))
    }, 500), this)

    this._throttledInteractions($(evt.target).data("id"))
  },

  refreshScrollSpy : function(){
    _.defer($('body').scrollspy('refresh'))
  }
},

//static methods
{
  InfiniteScrollView : app.views.InfScroll.extend({
    initialize: function(){
      this.stream = this.model
      this.collection = this.stream.items
      this.postClass = app.views.Post.StreamFrame
      this.setupInfiniteScroll()
    }
  })
});
