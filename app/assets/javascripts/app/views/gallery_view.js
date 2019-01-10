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
      continuous: true,
      toggleControlsOnReturn: false,
      onopened: this.preventHideControls,
      slideshowInterval: 2000,
      onslidecomplete: function(index, slide) {
        // If the image is very tall (more than twice its width), then it is scrollable instead of resized
        var image = slide.firstElementChild;
        if (image.naturalHeight > window.innerHeight && image.naturalHeight > image.naturalWidth * 2) {
          image.classList.add("too-tall");
        } else {
          var margins = 110; // Margins are 80px for thumbnails height and 15px for top image margin + scroll-x height
          image.style = "max-height: " + (window.innerHeight - margins) + "px";
        }
      }
    };
  }
});
