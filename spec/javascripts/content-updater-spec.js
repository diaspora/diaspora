/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("ContentUpdater", function() {
  describe("addPostToStream", function() {
    beforeEach(function() {
      spec.loadFixture("aspects_index");
      Diaspora.Page = "AspectsIndex";
      Diaspora.instantiatePage();
    });

    it("adds a post to the stream", function() {
      var originalPostCount = $(".stream_element").length;
      ContentUpdater.addPostToStream(spec.fixtureHtml("created_status_message"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
    });

    it("does not add duplicate posts", function() {
      var originalPostCount = $(".stream_element").length;
      ContentUpdater.addPostToStream(spec.fixtureHtml("created_status_message"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
      ContentUpdater.addPostToStream(spec.fixtureHtml("created_status_message"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
    });

    it("removes the div that says you have no posts if it exists", function() {
      expect($("#no_posts").length).toEqual(1);
      ContentUpdater.addPostToStream(spec.fixtureHtml("created_status_message"));
      expect($("#no_posts").length).toEqual(0);
    });
  });

  describe("removePostFromStream", function() {
    var post, postGUID;
    beforeEach(function() {
      spec.loadFixture("aspects_index_with_posts");
      post = $(".stream_element:first"),
        postGUID = post.attr("id");

      $.fx.off = true;
    });

    it("removes the post from the stream", function() {
      expect($("#" + postGUID).length).toEqual(1);
      ContentUpdater.removePostFromStream(postGUID);
      expect($("#" + postGUID).length).toEqual(0);
    });

    it("shows the div that says you have no posts if there are no more post", function() {
      $("#main_stream .stream_element").slice(1).remove();
      expect($("#no_posts")).toHaveClass("hidden");
      ContentUpdater.removePostFromStream(postGUID);
      expect($("#no_posts")).not.toHaveClass("hidden");
    });

    afterEach(function() {
      $.fx.off = false;
    });
  });

  describe("addCommentToPost", function() {
    var post, postGUID;
    beforeEach(function() {
      spec.loadFixture("aspects_index_with_posts");
      post = $(".stream_element:first"),
        postGUID = post.attr("id");


      Diaspora.page.stream = { streamElements: { } };

      Diaspora.page.stream.streamElements[postGUID] = {
        commentStream: {publish: $.noop}
      };
    });

    it("adds a comment to a post only if it doesn't already exist", function() {
      var comments = post.find("ul.comments li");

      ContentUpdater.addCommentToPost(postGUID, "978124", "<li id='978124'>Comment</li>");
      expect(post.find("ul.comments li").length).toEqual(comments.length + 1);

      ContentUpdater.addCommentToPost(postGUID, "978124", "<li id='978124'>Comment</li>");
      expect(post.find("ul.comments li").length).toEqual(comments.length + 1);
    });
  });

  describe("addLikesToPost", function() {
    var post, postGUID;
    beforeEach(function() {
      spec.loadFixture("aspects_index_with_posts");

      Diaspora.Page = "AspectsIndex";
      Diaspora.instantiatePage();

      post = $(".stream_element:first"),
        postGUID = post.attr("id");

    });

    it("adds the given html to a post's likes container", function() {
      jasmine.Clock.useMock();

      ContentUpdater.addLikesToPost(postGUID, "<p>1 like</p>");

      jasmine.Clock.tick(250);

      expect(post.find(".likes .likes_container").html()).toEqual("<p>1 like</p>");
    });

    afterEach(function() {
      $.fx.off = false;
    });
  });
});
