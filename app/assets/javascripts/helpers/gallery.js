Diaspora.Gallery = function(options) {
  if (options && options.el && $(options.el).length === 1) {
    this.$el = $(options.el);
  } else {
    this.$el = $("body");
  }

  this.$el.find("a.open-gallery").click(this.showGallery.bind(this));
};

Diaspora.Gallery.prototype = {
  constructor: Diaspora.Gallery,

  pictures: function() {
    return this.$el.find("a.gallery-picture");
  },

  showGallery: function(event) {
    event.preventDefault();
    event.stopPropagation();
    var target = event.target.src ? event.target.parentNode : event.target;
    var index = target;
    if (target.dataset.index) {
      index = target.dataset.index;
    }
    var links = this.pictures();
    blueimp.Gallery(links, this.options(event, index));
  },

  preventHideControls: function() {
    var lightbox = $("#blueimp-gallery");
    var onEvent = function(ev) {
      if ($(ev.target).hasClass("slide-content")) {
        ev.preventDefault();
        ev.stopPropagation();
      }
    };

    lightbox.find(".slide").click(onEvent);
  },

  options: function(event, link) {
    return {
      index: link,
      event: event,
      hidePageScrollbars: false,
      disableScroll: true,
      continuous: true,
      toggleControlsOnReturn: false,
      onopened: this.preventHideControls,
      slideshowInterval: 2000
    };
  }
};
