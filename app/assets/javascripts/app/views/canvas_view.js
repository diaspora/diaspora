app.views.Canvas = app.views.Base.extend(_.extend({}, app.views.infiniteScrollMixin,  {
  initialize: function(){
    this.stream = this.model
    this.collection = this.stream.items
    this.postClass = app.views.SmallFrame
    this.setupInfiniteScroll()
  },

  renderTemplate : function() {
    this.stream.items.each(_.bind(function(post){
      this.$el.append(this.createPostView(post).render().el);
    }, this))
    //needs to be defered so it happens after html rendering finishes
    _.defer(_.bind(this.mason, this))
  },

  addPostView : function(post) {
    _.defer(_.bind(function(){ this.$el.isotope("insert", this.createPostView(post).render().$el) }, this))
  },

    mason : function() {
    this.$el.isotope({
      itemSelector : '.canvas-frame',
      masonry : {
        columnWidth : 292.5
      }
    })
  }
}));
