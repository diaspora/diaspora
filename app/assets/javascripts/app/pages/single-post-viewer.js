app.pages.SinglePostViewer = app.views.Base.extend({
  templateName: "single-post-viewer",

  subviews : {
    "#single-post-content" : "singlePostContentView",
    '#single-post-interactions' : 'singlePostInteractionsView'
  },

  initialize : function(options) {
    this.model = new app.models.Post({ id : options.id });
    this.model.preloadOrFetch().done(_.bind(this.initViews, this));
    this.model.interactions.fetch() //async, yo, might want to throttle this later.
    this.setupLightbox()
  },

  setupLightbox : function(){
    this.lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
    this.lightbox.set({
      imageParent: '.photo_attachments',
      imageSelector: 'img.stream-photo'
    });
    this.$el.delegate("a.stream-photo-link", "click", this.lightbox.lightboxImageClicked);
  },

  initViews : function() {
    this.singlePostContentView = new app.views.SinglePostContent({model: this.model});
    this.singlePostInteractionsView = new app.views.SinglePostInteractions({model: this.model});
    this.render();
  },

  postRenderTemplate : function() {
    if(this.model.get("title")){
      // formats title to html...
      var html_title = app.helpers.textFormatter(this.model.get("title"), this.model);
      //... and converts html to plain text
      document.title = $('<div>').html(html_title).text();
      app.hovercard.deactivate() // No hovercards for now.
    }
  },

});
