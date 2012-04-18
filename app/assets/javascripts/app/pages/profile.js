//= require ../views/small_frame

app.pages.Profile = app.views.Base.extend(_.extend(app.views.infiniteScrollMixin, {

  templateName : "profile",

//  subviews : {
//    "#canvas" : "canvasView"
//  },

  initialize : function() {
    this.stream = this.model = this.model || new app.models.Stream()
    this.collection = this.model.posts
    this.model.fetch();

    this.stream.bind("fetched", this.mason, this)

//    this.initViews()

    this.setupInfiniteScroll()
  },

  postClass : app.views.SmallFrame,

  mason : function() {
    this.$el.isotope({
      itemSelector : '.canvas-frame'
    })
  }

//  initViews : function() {
//    this.canvasView = new app.views.Canvas({model : this.model})
//  }
}));