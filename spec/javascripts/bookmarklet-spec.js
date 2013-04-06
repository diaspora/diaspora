/*   Copyright (c) 2010-2012, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("bookmarklet", function() {

  describe("base functionality", function(){
    beforeEach( function(){
      spec.loadFixture('empty_bookmarklet');
    });

    it('verifies the publisher is loaded', function(){
      expect(typeof app.publisher === "object").toBeTruthy();
    });

    it('verifies we are using the bookmarklet', function(){
      expect(app.publisher.options.standalone).toBeTruthy();
      expect(app.publisher.$('#hide_publisher').is(':visible')).toBeFalsy();
    });
  });

  describe("prefilled bookmarklet", function(){
    it('fills in some text into the publisher', function(){
      spec.loadFixture('prefilled_bookmarklet');
      _.defer(function() {
        expect($("#publisher #status_message_fake_text").val() == "").toBeFalsy();
        expect($("#publisher #status_message_text").val() == "").toBeFalsy();
      });
    });

    it('handles dirty input well', function(){
      spec.loadFixture('prefilled_bookmarklet_dirty');
      _.defer(function() {
        expect($("#publisher #status_message_fake_text").val() == "").toBeFalsy();
        expect($("#publisher #status_message_text").val() == "").toBeFalsy();
      });
    });
  });
  
  describe("modified prefilled bookmarklet", function(){
    it('allows changing of post content', function(){
      spec.loadFixture('prefilled_bookmarklet');
      $('div.mentions > div').html('Foo Bar');
      _.defer(function() {
        expect($("#publisher #status_message_text").val()).toEqual("Foo Bar");
      });
    });
  });




});
