/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("ContentUpdater", function() {
  describe("addPostToStream", function() {
    var $post;
    beforeEach(function() {
      $("#jasmine_content").empty();
      spec.loadFixture("aspects_index");
      $post = $(spec.fixtureHtml("status_message_in_stream"));
    });
    it("adds a post to the stream", function() {
      var originalPostCount = $(".stream_element").length;
      ContentUpdater.addPostToStream($post.data("guid"), spec.fixtureHtml("status_message_in_stream"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
    });

    it("does not add duplicate posts", function() {
      var originalPostCount = $(".stream_element").length;
      ContentUpdater.addPostToStream($post.data("guid"), spec.fixtureHtml("status_message_in_stream"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
      ContentUpdater.addPostToStream($post.data("guid"), spec.fixtureHtml("status_message_in_stream"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
    });

    it("removes the div that says you have no posts if it exists", function() {
      expect($("#no_posts").length).toEqual(1);
      ContentUpdater.addPostToStream($post.data("guid"), spec.fixtureHtml("status_message_in_stream"));
      expect($("#no_posts").length).toEqual(0);
    });

    it("fires a custom event (stream/postAdded)", function() {
      var spy = jasmine.createSpy("stub");
      Diaspora.widgets.subscribe("stream/postAdded", spy);
      ContentUpdater.addPostToStream($post.data("guid"), spec.fixtureHtml("status_message_in_stream"));
      expect(spy).toHaveBeenCalled();
    });
  });

  describe("addCommentToPost", function() {
    var $comment, $post;

    beforeEach(function() {
      spec.loadFixture("aspects_index");
      $comment = $(spec.fixtureHtml("comment_on_status_message")),
        $post = $(spec.fixtureHtml("status_message_in_stream"));
    });

    it("adds a comment to a post only if it doesnt exist", function() {
      ContentUpdater.addPostToStream($post.data("guid"), spec.fixtureHtml("status_message_in_stream"))
      var originalCommentCount = $(".comment.posted").length;
      ContentUpdater.addCommentToPost($comment.data("guid"), $post.data("guid"), spec.fixtureHtml("comment_on_status_message"));
      expect($(".comment.posted").length).toEqual(originalCommentCount);
      ContentUpdater.addCommentToPost("9000786", $post.data("guid"), spec.fixtureHtml("comment_on_status_message"));
      expect($(".comment.posted").length).toBeGreaterThan(originalCommentCount);
    });
  });
});
