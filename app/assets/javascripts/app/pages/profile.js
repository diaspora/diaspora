//= require ../views/small_frame

app.pages.Profile = app.views.Base.extend(_.extend(app.views.infiniteScrollMixin, {

  templateName : "profile",

//  subviews : {
//    "#canvas" : "canvasView"
//  },

  initialize : function(options) {
    this.model = new app.models.Profile.findByGuid(options.personId)
    this.stream = options && options.stream || new app.models.Stream()
    this.collection = this.stream.posts
    this.stream.fetch();

    this.model.bind("change", this.render, this)

//    this.initViews()

//    this.setupInfiniteScroll()
  },

  postClass : app.views.SmallFrame,

//  mason : function() {
//    this.$el.isotope({
//      itemSelector : '.canvas-frame'
//    })
//  }

//  initViews : function() {
//    this.canvasView = new app.views.Canvas({model : this.model})
//  }
}));