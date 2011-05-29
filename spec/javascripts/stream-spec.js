/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Stream", function() {
  beforeEach(function() {
    jasmine.Clock.useMock();
    spec.loadFixture('aspects_index_with_posts');
    Diaspora.widgets.i18n.locale = { };
  });

  describe("initialize", function() {
    it("attaches a click event to show_post_comments links", function() {
      spyOn(Stream, "toggleComments");
      Stream.initialize();
      $('.stream a.show_post_comments').click();
      expect(Stream.toggleComments).toHaveBeenCalled();
    });

    it("adds a 'show more' links to long posts", function() {
      Diaspora.widgets.i18n.loadLocale(
        {show_more: 'Placeholder'}, 'en');
      Stream.initialize();
      stream_element = $('#main_stream .stream_element:first');
      expect(stream_element.find(".details").css('display')).toEqual('none');
      expect(stream_element.find(".read-more a").css('display')).toEqual('inline');
      stream_element.find(".read-more a").click();
      jasmine.Clock.tick(200);
      expect(stream_element.find(".read-more").css('display')).toEqual('none');
      expect(stream_element.find(".details").css('display')).toEqual('inline');
    });
  });

  describe("toggleComments", function() {
    it("toggles class hidden on the comment block", function () {
      link = $("a.show_post_comments");
      expect(jQuery('ul.comments .older_comments')).toHaveClass("hidden");
      Stream.toggleComments.call(
        link, {preventDefault: function(){} }
      );
      jasmine.Clock.tick(200);
      expect(jQuery('ul.comments .older_comments')).not.toHaveClass("hidden");
    });

    it("changes the text on the show comments link", function() {
      link = $("a.show_post_comments");
      Diaspora.widgets.i18n.loadLocale(
        {'comments' : {'hide': 'comments.hide pl'}}, 'en');
      expect(link.text()).toEqual("show all comments");
      Stream.toggleComments.call(
        link, {preventDefault: function(){} }
      );
      jasmine.Clock.tick(400);
      expect(link.text()).toEqual("comments.hide pl");
    });
  });
});
