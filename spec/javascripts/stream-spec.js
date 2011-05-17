/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
function randomString(string_length) {
  var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz     ";
  var randomstring = '';
  for (var i=0; i<string_length; i++) {
    var rnum = Math.floor(Math.random() * chars.length);
    randomstring += chars.substring(rnum,rnum+1);
  }
  return randomstring;
}

describe("Stream", function() {
  beforeEach(function() {
    jasmine.Clock.useMock();
    spec.loadFixture('aspects_index_with_posts');
  });

  describe("initialize", function() {
    it("attaches a click event to show_post_comments links", function() {
      spyOn(Stream, "toggleComments");
      Stream.initialize();
      $('.stream a.show_post_comments').click();
      expect(Stream.toggleComments).toHaveBeenCalled();
    });

    it("adds a 'show more' links to long posts", function() {
      $("#jasmine_content").html(
        '<li class="stream_element">' +
          '<div class="content">' +
            '<p id="text">' +
              randomString(1000) +
            '</p>' +
          '</div>' +
        '</li>'
      );
      Stream.initialize();
      expect($(".details").css('display')).toEqual('none');
      expect($(".read-more a").css('display').toEqual('inline');
      expect($(".re-collapse a").css('display')).toEqual('none');
      $(".read-more a").click();
      jasmine.Clock.tick(200);
      expect($(".read-more a").css('display').toEqual('none');
      expect($(".re-collapse a").css('display')).toEqual('inline');
      expect($(".details").css('display')).toEqual('inline');
    });
  });

  describe("toggleComments", function() {
    beforeEach(function(){
      jQuery('#main_stream a.show_post_comments:not(.show)').die();
      Stream.initialize();
    });
    it("toggles class hidden on the comment block", function () {
      expect(jQuery('ul.comments')).not.toHaveClass("hidden");
      $("a.show_post_comments").click();
      jasmine.Clock.tick(200);
      expect(jQuery('ul.comments')).toHaveClass("hidden");
    });

    it("changes the text on the show comments link", function() {
      expect($("a.show_post_comments").text()).toEqual("hide comments (1)");
      $("a.show_post_comments").click();
      jasmine.Clock.tick(200);
      expect($("a.show_post_comments").text()).toEqual("show comments (1)");
    });
  });
});
