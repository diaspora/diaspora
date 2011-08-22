/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Diaspora.Widgets.CommentToggler", function() {
  var commentToggler;
  beforeEach(function() {
    jasmine.Clock.useMock();
    spec.loadFixture("aspects_index_with_posts");
    Diaspora.I18n.locale = { };
    commentToggler = Diaspora.BaseWidget.instantiate("CommentToggler", $(".stream_element:first ul.comments"));
  });

  describe("toggleComments", function() {
    it("toggles class hidden on the comments ul", function () {
      expect($("ul.comments:first")).not.toHaveClass("hidden");
      commentToggler.hideComments($.Event());
      jasmine.Clock.tick(200);
      expect($("ul.comments:first")).toHaveClass("hidden");
    });

    it("changes the text on the show comments link", function() {
      var link = $("a.toggle_post_comments:first");
      Diaspora.I18n.loadLocale({'comments' : {'show': 'comments.show pl'}}, 'en');
      expect(link.text()).toEqual("Hide all comments");
      commentToggler.hideComments($.Event());
      jasmine.Clock.tick(200);
      expect(link.text()).toEqual("comments.show pl");
    });
  });
});
