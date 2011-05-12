/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

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
