app.views.Canvas = app.views.Base.extend(_.extend({}, app.views.infiniteScrollMixin,  {
  initialize: function(){
    this.stream = this.model
    this.collection = this.stream.items
    this.postClass = app.views.SmallFrame
    this.setupInfiniteScroll()
    this.stream.bind("reLayout", this.reLayout, this)
    this.stream.bind("fetched", this.triggerRelayoutAfterImagesLoaded, this)
  },

  renderTemplate : function() {
    this.$el.empty()
    this.stream.items.each(_.bind(function(post){
      this.$el.append(this.createPostView(post).render().el);
    }, this))

    //needs to be deferred so it happens after html rendering finishes
    _.defer(_.bind(this.mason, this))
  },

  addPostView : function(post) {
    _.defer(_.bind(function(){ this.$el.isotope("insert", this.createPostView(post).render().$el) }, this))
  },

  mason : function() {
    var el = this.$el;
    el.imagesLoaded(function(){
      el.isotope({
        itemSelector : '.canvas-frame',
        visibleStyle : {scale : 1},
        hiddenStyle : {scale : 0.001},
        containerStyle : {position : "relative"},
        masonry : {
          columnWidth : 292.5
        }
      })
    })
  },

  triggerRelayoutAfterImagesLoaded : function(){
    this.$el.imagesLoaded(_.bind(this.reLayout, this))
  },

  reLayout : function(){
    this.$el.isotope("reLayout")
  }
}));
