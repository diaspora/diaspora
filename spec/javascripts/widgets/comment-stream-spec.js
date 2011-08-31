describe("Diaspora.Widgets.CommentStream", function() {
  var commentStream;
  beforeEach(function() {
    spec.readFixture("ajax_comments_on_post");

    jasmine.Clock.useMock();
    jasmine.Ajax.useMock();

    spec.loadFixture("aspects_index_with_posts");
    Diaspora.I18n.locale = { };

    var post = $(".stream_element:first"),
      postGUID = post.attr("id");

    commentStream = Diaspora.BaseWidget.instantiate("CommentStream", $(".stream_element:first .comment_stream"));
  });

  describe("toggling comments", function() {
    it("toggles class hidden on the comments ul", function () {
      spyOn($, "ajax").andCallThrough();

      expect($("ul.comments:first")).not.toHaveClass("hidden");

      commentStream.showComments($.Event());

      mostRecentAjaxRequest().response({
        responseHeaders: {
          "Content-type": "text/html"
        },
        responseText: spec.readFixture("ajax_comments_on_post"),
        status: 200
      });

      jasmine.Clock.tick(200);

      expect($("ul.comments:first")).not.toHaveClass("hidden");

      commentStream.hideComments($.Event());

      jasmine.Clock.tick(200);

      expect($("ul.comments:first")).toHaveClass("hidden");
    });

    it("changes the text on the show comments link", function() {
      spyOn($, "ajax").andCallThrough();
      Diaspora.I18n.loadLocale({'comments' : {
        'show': 'show comments translation',
        'hide': 'hide comments translation'
      }}, 'en');

      var link = $("a.toggle_post_comments:first");

      commentStream.showComments($.Event());

     mostRecentAjaxRequest().response({
        responseHeaders: {
          "Content-type": "text/html"
        },
        responseText: spec.readFixture("ajax_comments_on_post"),
        status: 200
      });

      jasmine.Clock.tick(200);

      expect(link.text()).toEqual("hide comments translation");

      commentStream.hideComments($.Event());

      jasmine.Clock.tick(200);

      expect(link.text()).toEqual("show comments translation");
    });

    it("only requests the comments when the loaded class is not present", function() {
      spyOn($, "ajax").andCallThrough();
      
      expect(commentStream.commentsList).not.toHaveClass("loaded");

      commentStream.showComments($.Event());

      mostRecentAjaxRequest().response({
        responseHeaders: {
          "Content-type": "text/html"
        },
        responseText: spec.readFixture("ajax_comments_on_post"),
        status: 200
      });


      expect($.ajax.callCount).toEqual(1);
      expect(commentStream.commentsList).toHaveClass("loaded");

      commentStream.showComments($.Event());

      expect($.ajax.callCount).toEqual(1);
      expect(commentStream.commentsList).toHaveClass("loaded");
    });
  });
});