app.views.Canvas = app.views.Base.extend(_.extend({}, app.views.infiniteScrollMixin,  {
  initialize: function(){
    this.stream = this.model
    this.collection = this.stream.items
    this.postClass = app.views.SmallFrame
    this.setupInfiniteScroll()
    this.stream.bind("reLayout", this.reLayout, this)
  },

  renderTemplate : function() {
    this.$el.empty()
    this.stream.items.each(_.bind(function(post){
      this.$el.append(this.createPostView(post).render().el);
    }, this))

    //needs to be deferred so it happens after html rendering finishes
    _.delay(_.bind(this.mason, this), 0)

    this.triggerReLayouts()
  },

  addPostView : function(post) {
    _.defer(_.bind(function(){ this.$el.isotope("insert", this.createPostView(post).render().$el) }, this))
  },

  mason : function() {
    this.$el.isotope({
      itemSelector : '.canvas-frame',
      visibleStyle : {scale : 1},
      hiddenStyle : {scale : 0.001},
      masonry : {
        columnWidth : 292.5
      }
    })
  },

  reLayout : function(){
    this.$el.isotope("reLayout")
  },

  triggerReLayouts : function(){
    // Images load slowly, which setting the height of the dom elements, use these hax for the momment to reLayout the page
    // ever little bit for a while after loading
    // gross hax, bro ;-p

    _.delay(_.bind(this.reLayout, this), 200)
    _.delay(_.bind(this.reLayout, this), 500)
    _.delay(_.bind(this.reLayout, this), 1000)
    _.delay(_.bind(this.reLayout, this), 3000)
    _.delay(_.bind(this.reLayout, this), 5000)
  }
}));
