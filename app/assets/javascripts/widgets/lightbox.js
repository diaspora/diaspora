/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
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

    self.options = {
      imageParent: '.stream_element',
      imageSelector: 'img.stream-photo'
    };

    this.subscribe("widget/ready", function(evt) {
      $.extend(self, {
        lightbox: $("#lightbox"),
        imageset: $("#lightbox-imageset"),
        backdrop: $("#lightbox-backdrop"),
        closelink: $("#lightbox-close-link"),
        image: $("#lightbox-image"),
        body: $(document.body),
        window: $(window)
      });

      //self.post.delegate("a.stream-photo-link", "click", self.lightboxImageClicked);
      self.imageset.delegate("img", "click", self.imagesetImageClicked);

      self.window.resize(function() {
        self.lightbox.css("max-height", (self.window.height() - 100) + "px");
      }).trigger("resize");

      self.closelink.click(function(evt){
        evt.preventDefault();
        self.resetLightbox();
      });
      self.backdrop.click(self.resetLightbox);
      self.lightbox.click(self.resetLightbox);

      self.backdrop.click(function(evt) {
        evt.preventDefault();
        self.resetLightbox();
      });

      self.body.keydown(function(evt) {
        var imageThumb = self.imageset.find("img.selected");

        switch(evt.keyCode) {
        case 27:
          self.resetLightbox();
          break;
        case 37:
          //left
          self.selectImage(self.prevImage(imageThumb));
          break;
        case 39:
          //right
          self.selectImage(self.nextImage(imageThumb));
          break;
        }
      });
    });

    this.nextImage = function(thumb){
      var next = thumb.next();
      if (next.length == 0) {
        next = self.imageset.find("img").first();
      }
      return(next);
    };

    this.prevImage = function(thumb){
      var prev = thumb.prev();
      if (prev.length == 0) {
        prev = self.imageset.find("img").last();
      }
      return(prev);
    };

    this.lightboxImageClicked = function(evt) {
      evt.preventDefault();

      var selectedImage = $(this).find(self.options.imageSelector),
        imageUrl = selectedImage.attr("data-full-photo"),
        images = selectedImage.parents(self.options.imageParent).find(self.options.imageSelector),
        imageThumb;

      if( $.browser.msie ) {
        /* No fancy schmancy lightbox for IE, because it doesn't work in IE */
        window.open(imageUrl);
        return;
      }

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
      evt.stopPropagation();

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
      self.image.attr("src", "assets/ajax-loader2.gif");
      self.imageset.html("");
    };

    this.set = function(opts) {
      $.extend(self.options, opts);
    };
  };

  Diaspora.Widgets.Lightbox = Lightbox;
})();
