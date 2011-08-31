describe("Diaspora.Widgets.Likes", function() {
  var likes;
  beforeEach(function() {
    spec.readFixture("ajax_likes_on_post");
    spec.loadFixture("aspects_index_with_a_post_with_likes");
    likes = Diaspora.BaseWidget.instantiate("Likes", $(".stream_element .likes_container"));
    jasmine.Ajax.useMock();
    $.fx.off = true;
  });

  describe("integration", function() {
    beforeEach(function() {
      likes = new Diaspora.Widgets.Likes();

      spyOn(likes, "expandLikes");

      likes.publish("widget/ready", [$(".stream_element .likes_container")]);
    });

    it("calls expandLikes when you click on the expand likes link", function() {
      $(".stream_element a.expand_likes").click();

      expect(likes.expandLikes).toHaveBeenCalled();
    });
  });

  describe("expandLikes", function() {
    it("makes an ajax request if the list does not have children", function() {
      spyOn($, "ajax");

      likes.expandLikes($.Event());

      expect($.ajax).toHaveBeenCalled();
    });

    it("does not make an ajax request if the list has children", function() {
      spyOn($, "ajax");

      $(".stream_element .likes_list").html("<span></span>");

      likes.expandLikes($.Event());

      expect($.ajax).not.toHaveBeenCalled();
    });

    it("makes the likes list's html the response of the request", function() {
      spyOn($, "ajax").andCallThrough();

      likes.expandLikes($.Event());

      mostRecentAjaxRequest().response({
        responseHeaders: {
          "Content-type": "text/html"
        },
        responseText: spec.readFixture("ajax_likes_on_post"),
        status: 200
      });

      expect($(".stream_element .likes_list").html()).toEqual(spec.readFixture("ajax_likes_on_post"));
    });
  });

  afterEach(function() {
    $.fx.off = false;
  });
});
