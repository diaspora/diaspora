app.views.NewStream = app.views.InfScroll.extend({
  initialize: function(){
    this.stream = this.model
    this.collection = this.stream.items
    this.postClass = app.views.Post.StreamFrame
    this.setupInfiniteScroll()
  }
});

/*--------------------*/

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
    this.stream.preloadOrFetch();

    this.streamView = new app.views.NewStream({ model : this.stream })
    var interactions = this.interactionsView = new app.views.StreamInteractions()

    this.setUpThrottledInteractionScroll();

    this.stream.on("frame:interacted", function(post){
      interactions.setInteractions(post)
    })
  },

  postRenderTemplate : function() {
    this.$("#header").css("background-image", "url(" + app.currentUser.get("wallpaper") + ")")

   _.defer(function(){$('body').scrollspy({target : '.stream-frame-wrapper', offset : 50})})


    this.setUpHashChangeOnStreamLoad()
  },

  setUpThrottledInteractionScroll : function(){
    this.focusedPost = undefined;
    var self = this;
    this.updateInteractions = _.throttle(function(){
          console.log("firing for " + self.focusedPost.get('id'));
          self.interactionsView.setInteractions(self.focusedPost)
        }, 1000)
  },

  setUpHashChangeOnStreamLoad : function(){
    var self = this;
    this.streamView.on('loadMore', function(){
      var post = this.stream.items.last();
      if(post){
        self.navigateToPost(post)
      }
      self.refreshScrollSpy()
    });
  },

  navigateToPost : function(post){
    app.router.navigate(location.pathname + "?ex=true&max_time=" + post.createdAt(), {replace: true})
  },


  triggerInteractionLoad : function(evt){
    var id = $(evt.target).data("id");
    console.log("calling triggerInteractiosns for: " + id)
    this.focusedPost = this.stream.items.get(id)
    this.updateInteractions()
  },

  //on active guid => this guid
  // fire interacted from stream collection w/guid
  refreshScrollSpy : function(){
    setTimeout(function(){
      $('body').scrollspy('refresh')
    }, 2000)
  }
});
