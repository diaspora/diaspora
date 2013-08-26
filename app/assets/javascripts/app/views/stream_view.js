//= require ./stream/shortcuts

app.views.Stream = app.views.InfScroll.extend(_.extend(
  app.views.StreamShortcuts, {
  	
  initialize: function(options) {
    this.stream = this.model
    this.collection = this.stream.items

    this.postViews = []

    this.setupNSFW()
    this.setupLightbox()
    this.setupInfiniteScroll()
    this.setupShortcuts()
    this.markNavSelected()
  },

  postClass : app.views.StreamPost,

  setupLightbox : function(){
    this.lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
    this.$el.delegate("a.stream-photo-link", "click", this.lightbox.lightboxImageClicked);
  },

  setupNSFW : function(){
    app.currentUser.bind("nsfwChanged", reRenderPostViews, this)

    function reRenderPostViews() {
      _.map(this.postViews, function(view){ view.render() })
    }
  },

  markNavSelected : function() {
    var activeStream = Backbone.history.fragment;
    var streamSelection = $("#stream_selection");
    streamSelection.find("[data-stream]").removeClass("selected");
    streamSelection.find("[data-stream='" + activeStream + "']").addClass("selected");
  }
}));
