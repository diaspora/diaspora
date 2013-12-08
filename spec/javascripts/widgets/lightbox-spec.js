/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Diaspora.Widgets.Lightbox", function() {
  var photos;

  var createDummyMarkup = function(opts){
    var defaults = {
      linkClass: 'stream-photo-link',
      imageParent: 'stream_element',
      imageClass: 'stream-photo'
    };

    classes = _.extend(defaults, opts);
    
    var output = $('<div/>').addClass(classes.imageParent);
    _.each(photos, function(photo){
      output.append(
        $('<a />')
          .attr('href', '#')
          .addClass(classes.linkClass)
          .append(
            $('<img />')
              .attr('src', photo.sizes.large)
              .addClass(classes.imageClass)
              .data({
                'small-photo': photo.sizes.small,
                'full-photo': photo.sizes.large
              })
          )
      );
    });
    
    return output;
  };
  
  beforeEach(function(){
    $("#jasmine_content").html(
      '<div id="lightbox" style="display: none;">TESTCONTENT</div>' +
      '<div id="lightbox-imageset"></div>' +
      '<div id="lightbox-backdrop"></div>' +
      '<div id="lightbox-close-link"></div>'
    );

    photos = $.parseJSON(spec.readFixture("photos_json"))["photos"];
  });
  
  context("opens the lightbox correctly", function() {
    var lightbox, page, photoElement;
    
    beforeEach(function() {
      $("#jasmine_content").append(createDummyMarkup());
      photoElement = $('.stream-photo').first();
      
      lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
      $('.stream_element').delegate("a.stream-photo-link", "click", lightbox.lightboxImageClicked);
    });
      
    it("shows the lightbox when a photo is clicked", function() {
      spyOn(lightbox, 'revealLightbox');
      photoElement.trigger('click');
      expect(lightbox.revealLightbox).toHaveBeenCalled();
    });
    
  });

  context("opens lightbox for differently named elements", function(){
    var lightbox, page, photoElement;

    beforeEach(function() {
      $("#jasmine_content").append(createDummyMarkup({
        linkClass: 'photo-link',
        imageParent: 'main_stream',
        imageClass: 'photo'
      }));
      photoElement = $('.photo').first();

      lightbox = Diaspora.BaseWidget.instantiate("Lightbox");
      lightbox.set({
        imageParent: '.main_stream',
        imageSelector: 'img.photo'
      });
      $('.main_stream').delegate("a.photo-link", "click", lightbox.lightboxImageClicked);
    });

    it("shows the lightbox when a photo is clicked", function() {
      spyOn(lightbox, 'revealLightbox');
      photoElement.trigger('click');
      expect(lightbox.revealLightbox).toHaveBeenCalled();
    });
  });
  
});
