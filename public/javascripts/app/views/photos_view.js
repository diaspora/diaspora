app.views.Photos = Backbone.View.extend({

  events : {},

  initialize : function(options) {
    this.photos = this.model;
    this.collection = this.model.photos;

    this.setupEvents();
    //this.setupLightbox(); ERROR: "imageThumb is undefined" ...
  },

  setupEvents : function(){
    this.photos.bind("fetched", this.removeLoader, this)
    this.collection.bind("add", this.addPhoto, this);
  },

  addPhoto : function(photo) {
    var photoView = new app.views.Photo({ model: photo });

    $(this.el)[
      (this.collection.at(0).id == photo.id)
        ? "prepend"
        : "append"
    ](photoView.render().el);

    return this;
  },

  render : function(evt) {
    if(evt) {evt.preventDefault(); }

    if(this.model.fetch()) {
      this.appendLoader();
    };
    
    return this;
  },

  appendLoader: function(){
    $("#paginate").html($("<img>", {
      src : "/images/static-loader.png",
      "class" : "loader"
    }));
  },

  removeLoader: function() {
    $("#paginate").empty();
  },

  setupLightbox : function(){
    this.lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
    $(this.el).delegate("a.photo-link", "click", this.lightbox.lightboxImageClicked);
  },

});