/*   Copyright (c) 2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */


jQuery.fn.center = (function() {
  var $window = $(window);
  return function () {
    this.css({
      position: "absolute",
      top: ($window.height() - this.height()) / 2 + $window.scrollTop() + "px",
      left:($window.width() - this.width()) / 2 + $window.scrollLeft() + "px"
    });
    return this;
  };
})();

(function() {
  var Lightbox = function() {
    var self = this;

    this.start = function() {
      $.extend(self, {
        lightbox: $("#lightbox"),
        imageset: $("#lightbox-imageset"),
        backdrop: $("#lightbox-backdrop"),
        image: $("#lightbox-image"),
        stream: $("#main_stream"),
        body: $(document.body),
        window: $(window)
      });
      
      self.stream.delegate("a", "click", self.lightboxImageClicked);
      self.imageset.delegate("img", "click", self.imagesetImageClicked);

      self.window.resize(function() {
        self.lightbox.css("max-height", (self.window.height() - 100) + "px");
      }).trigger("resize");

      self.body.keydown(function(evt) {
        if(evt.keyCode == 27){
          self.resetLightbox();
        }
      });
    };

    this.lightboxImageClicked = function(evt) {
      evt.preventDefault();
      
      var selectedImage = $(this).find("img.stream-photo"),
          imageUrl = selectedImage.attr("data-full-photo"),
          images = selectedImage.parents('.stream_element').find('img.stream-photo'),
          imageThumb;

      self.imageset.html("");
      images.each(function(index, image) {
        image = $(image);
        var thumb = $("<img/>", {
          src: image.attr("data-small-photo"),
          "data-full-photo": image.attr("data-full-photo")
        });
        
        if(image.attr("data-full-photo") == imageUrl) {
          imageThumb = thumb;
        };

        self.imageset.append(thumb);
      });

      self
        .selectImage(imageThumb)
        .revealLightbox();
    };

    this.imagesetImageClicked = function(evt) { 
      evt.preventDefault();
      
      self.selectImage($(this));
    };

    this.selectImage = function(imageThumb) {
      $(".selected", self.imageset).removeClass("selected");
      imageThumb.addClass("selected");
      self.image.attr("src", imageThumb.attr("data-full-photo"));

      return self;
    };

    this.revealLightbox = function() {
      self.body.addClass("lightboxed");
      self.lightbox
        .css("max-height", (self.window.height() - 100) + "px")
        .show();

      return self;
    };

    this.resetLightbox = function() {
      self.lightbox.hide();
      self.body.removeClass("lightboxed");
    };
  };

  Diaspora.widgets.add("lightbox", Lightbox);
})();
