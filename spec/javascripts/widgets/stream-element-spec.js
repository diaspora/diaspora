/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Diaspora.Widgets.StreamElement", function() {
  var streamElement;

  beforeEach(function() {
    jasmine.Clock.useMock();
    spec.loadFixture("aspects_index_with_posts");
    streamElement = Diaspora.BaseWidget.instantiate("StreamElement", $(".stream_element:has(a.stream_element_delete.vis_hide)"));
  });

  describe("hidePost", function() {
    it("makes sure that ajax spinner appears when hiding a post", function() {
      expect(streamElement.deletePostLink).not.toHaveClass("hidden");
      expect(streamElement.hidePostLoader).toHaveClass("hidden");
      spyOn($, "ajax");
      streamElement.deletePostLink.click();
      jasmine.Clock.tick(200);
      expect($.ajax).toHaveBeenCalled();
      expect(streamElement.deletePostLink).toHaveClass("hidden");
      expect(streamElement.hidePostLoader).not.toHaveClass("hidden");
    });
  });
});
