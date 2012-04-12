app.views.Canvas = app.views.Base.extend({

  templateName : 'canvas',

  postRenderTemplate : function() {
    setTimeout(_.bind(this.mason, this), 0)
  },

  mason : function() {
    this.$el.isotope({
      itemSelector : '.canvas-frame'
    })
  }
})
