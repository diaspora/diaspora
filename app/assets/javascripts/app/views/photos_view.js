// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

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
// @license-end

