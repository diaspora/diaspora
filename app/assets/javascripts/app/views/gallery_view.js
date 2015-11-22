app.views.Gallery = app.views.Base.extend({
  events: {
    "click a.gallery-picture": "showGallery"
  },

  pictures: function(){
    return this.$el.find("a.gallery-picture");
  },

  showGallery: function(event){
    event = event || window.event;
    var target = event.target || event.srcElement;
    var link = target.src ? target.parentNode : target;
    var links = this.pictures();
    blueimp.Gallery(links, this.options(event, link));
  },

  preventHideControls: function(){
    var lightbox = $("#blueimp-gallery");
    var onEvent = function(ev){
      if($(ev.target).hasClass("slide-content")){
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
});
