app.views.NewStream = app.views.InfScroll.extend({
  initialize: function(){
    this.stream = this.model
    this.collection = this.stream.items
    this.postClass = app.views.Post.StreamFrame
    this.setupInfiniteScroll()
  }
});

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

    this.streamView = new app.views.NewStream({ model : this.stream })
    var interactions = this.interactionsView = new app.views.StreamInteractions()

    this.stream.on("frame:interacted", function(post){
      interactions.setInteractions(post)
    })

    this.streamView.on('loadMore', this.updateUrlState, this);
    this.stream.on("fetched", this.refreshScrollSpy, this)
  },

  postRenderTemplate : function() {
    this.$("#header").css("background-image", "url(" + app.currentUser.get("wallpaper") + ")")
   _.defer(function(){$('body').scrollspy({target : '.stream-frame-wrapper', offset : 50})})
  },

  updateUrlState : function(){
    var post = this.stream.items.last();
    if(post){
      this.navigateToPost(post)
    }
  },

  navigateToPost : function(post){
    app.router.navigate(location.pathname + "?ex=true&max_time=" + post.createdAt(), {replace: true})
  },

  triggerInteractionLoad : function(evt){
    var id = $(evt.target).data("id");
    this.focusedPost = this.stream.items.get(id)

    this._throttledInteractions = this._throttledInteractions || _.bind(_.throttle(this.updateInteractions, 1000), this)
    this._throttledInteractions()
  },

  updateInteractions: function () {
    this.interactionsView.setInteractions(this.focusedPost)
  },

  refreshScrollSpy : function(){
    _.defer($('body').scrollspy('refresh'))
  }
});
