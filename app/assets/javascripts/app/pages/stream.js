app.views.NewStream = app.views.Base.extend(_.extend({}, app.views.infiniteScrollMixin, {
  initialize: function(){
    this.stream = this.model
    this.collection = this.stream.items
    this.postClass = app.views.SmallFrame
    this.setupInfiniteScroll()
  }
}));

app.pages.Stream = app.views.Base.extend({
  templateName : "stream",

  subviews : {
    "#stream-content" : "streamView"
  },

  initialize : function(){
    this.stream = this.model = new app.models.Stream()
    this.stream.preloadOrFetch();

    this.streamView = new app.views.NewStream({ model : this.stream })
  }
});
