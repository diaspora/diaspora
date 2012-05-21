app.views.Photos = app.views.InfScroll.extend({
  initialize : function(options) {
    this.stream = this.model;
    this.collection = this.stream.items;

    // viable for extraction
    this.stream.fetch();

    this.setupLightbox()
    this.setupInfiniteScroll()
  },

  postClass : app.views.Photo,

  setupLightbox : function(){
    this.lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
    this.lightbox.set({
      imageParent: '#main_stream',
      imageSelector: 'img.photo'
    });
    $(this.el).delegate("a.photo-link", "click", this.lightbox.lightboxImageClicked);
  }
});
