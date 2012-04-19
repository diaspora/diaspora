app.views.Canvas = app.views.Base.extend(_.extend(app.views.infiniteScrollMixin, {
  initialize: function(){
    this.stream = this.model
    this.collection = this.stream.items
    this.postClass = app.views.SmallFrame,
    this.setupInfiniteScroll()
  },

  renderTemplate : function() {
    this.postRenderTemplate();
//   setTimeout(_.bind(this.mason, this), 1000)
  },
//
//  mason : function() {
//    this.$el.isotope({
//      itemSelector : '.canvas-frame'
//    })
//  }
}))
