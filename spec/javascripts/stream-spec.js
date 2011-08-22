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

  describe("collapseText", function() {
    it("adds a 'show more' links to long posts", function() {
      Diaspora.I18n.loadLocale({show_more: 'Placeholder'}, 'en');

      var stream_element = $('#main_stream .stream_element:first');
      Stream.collapseText('eventID', stream_element[0]);

      expect(stream_element.find("p .details").css('display')).toEqual('none');
      expect(stream_element.find(".read-more a").css('display')).toEqual('inline');

      stream_element.find(".read-more a").click();
      jasmine.Clock.tick(200);

      expect(stream_element.find(".read-more").css('display')).toEqual('none');
      expect(stream_element.find(".details").css('display')).toEqual('inline');
    });
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

  describe("initialize", function() {
    it("calls collapseText",function(){
      spyOn(Stream, "collapseText");
      Stream.initialize();
      expect(Stream.collapseText).toHaveBeenCalled();
    })
  });

});
