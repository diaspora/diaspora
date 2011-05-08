/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/
describe("ContentUpdates", function() {
  describe("addPostToStream", function() {
    beforeEach(function() {
      $("#jasmine_content").empty();
      spec.loadFixture("aspects_index_with_posts");
    });

    it("adds a post to the stream", function() {
      var originalPostCount = $(".stream_element").length;
      ContentUpdates.addPostToStream("guid", spec.fixtureHtml("status_message_in_stream"));
      expect($(".stream_element").length).toBeGreaterThan(originalPostCount);
    });

    it("does not add duplicate posts", function() {
      ContentUpdates.addPostToStream("guid", spec.fixtureHtml("status_message_in_stream"));
      var originalPostCount = $(".stream_element").length;
      ContentUpdates.addPostToStream("guid", spec.fixtureHtml("status_message_in_stream"));
      expect($(".stream_element").length).toEqual(originalPostCount);
    });

    it("removes the div that says you have no posts if it exists", function() {
      spec.loadFixture("aspects_index");
      expect($("#no_posts").length).toEqual(1);
      ContentUpdates.addPostToStream("guid", spec.fixtureHtml("status_message_in_stream"));
      expect($("#no_posts").length).toEqual(0);
    });
  });
});
