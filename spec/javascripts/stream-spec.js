/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Stream", function() {
  beforeEach(function() {
    jasmine.Clock.useMock();
    spec.loadFixture('aspects_index_with_posts');
    Diaspora.I18n.locale = { };
  });

  describe("streamElement", function() {
    it("makes sure that ajax spinner appears when hiding a post", function() {
      Stream.initializeLives();
      link = $("a.stream_element_delete.vis_hide");
      spinner = link.next("img.hide_loader");
      expect(link).not.toHaveClass("hidden");
      expect(spinner).toHaveClass("hidden");
      spyOn($, "ajax");
      link.click();
      expect($.ajax).toHaveBeenCalled();
      expect(link).toHaveClass("hidden");
      expect(spinner).not.toHaveClass("hidden");
    });
  });
});
