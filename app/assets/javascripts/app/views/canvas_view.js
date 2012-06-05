app.views.Canvas = app.views.InfScroll.extend({
  initialize: function(){
    this.stream = this.model
    this.collection = this.stream.items
    this.postClass = app.views.Post.CanvasFrame
    this.postViews = []
    this.setupInfiniteScroll()
    this.stream.bind("reLayout", this.reLayout, this)
    this.stream.bind("fetched", this.triggerRelayoutAfterImagesLoaded, this)
  },

  renderTemplate : function() {
    this.stream.deferred.done(_.bind(function(){
      if(this.stream.items.isEmpty()){
        var message
          , person = app.page.model
        if(person.get("is_own_profile")){
          message = "Make something to start the magic."
        } else {
          var name = person.get("name") || ""
          message = name + " hasn't posted anything yet."
        }

        this.$el.html("<p class='no-post-message'>" + message + "</p>")
      } else {
        this.renderInitialPosts()
      }

      //needs to be deferred so it happens after html rendering finishes
      _.defer(_.bind(this.mason, this))
    }, this))
  },

  addPostView : function(post) {
    _.defer(_.bind(function(){ this.$el.isotope("insert", this.createPostView(post).render().$el) }, this))
  },

  mason : function() {
    var el = this.$el;

    /* make two calls to isotope
       1) on dom ready
       2) on images ready
     */
    triggerIsotope(el) && el.imagesLoaded(_.bind(function(){
      this.reLayout()
    },this))

    function triggerIsotope(element) {
      return element.isotope({
        itemSelector : '.canvas-frame',
        visibleStyle : {scale : 1},
        hiddenStyle : {scale : 0.001},
        containerStyle : {position : "relative"},
        masonry : {
          columnWidth : 292.5
        }
      })
    }
  },

  triggerRelayoutAfterImagesLoaded : function(){
    //event apparently only fires once
    this.$el.imagesLoaded(_.bind(this.reLayout, this))
  },

  reLayout : function(){
    this.$el.isotope("reLayout")
  }
});
