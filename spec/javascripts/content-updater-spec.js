/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("ContentUpdater", function() {
  describe("addPostToStream", function() {

    beforeEach(function() {
      $("#jasmine_content").empty();
      spec.loadFixture("aspects_index");
    });

    it("adds a post to the stream", function() {
      var originalPostCount = $(".stream_element").length;
      ContentUpdater.addPostToStream(spec.fixtureHtml("status_message_in_stream"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
    });

    it("does not add duplicate posts", function() {
      var originalPostCount = $(".stream_element").length;
      ContentUpdater.addPostToStream(spec.fixtureHtml("status_message_in_stream"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
      ContentUpdater.addPostToStream(spec.fixtureHtml("status_message_in_stream"));
      expect($(".stream_element").length).toEqual(originalPostCount + 1);
    });

    it("removes the div that says you have no posts if it exists", function() {
      expect($("#no_posts").length).toEqual(1);
      ContentUpdater.addPostToStream(spec.fixtureHtml("status_message_in_stream"));
      expect($("#no_posts").length).toEqual(0);
    });
  });
});
