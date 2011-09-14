/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Diaspora.Widgets.Embedder", function() {
  var embedder;

  beforeEach(function() {
    spec.loadFixture("aspects_index_with_posts");
    embedder = Diaspora.BaseWidget.instantiate("Embedder", $(".stream_element .content"));
  });

  describe("services", function() {
    it("is an object containing all the supported services", function() {
      expect(typeof embedder.services === "object").toBeTruthy();
    });
  });
  describe("register", function() {
    it("adds a service and it's template to embedder.services", function() {
      expect(typeof embedder.services["ohaibbq"] === "undefined").toBeTruthy();
      embedder.register("ohaibbq", "sup guys");
      expect(typeof embedder.services["ohaibbq"] === "undefined").toBeFalsy();
    });
  });
  describe("render", function() {
    beforeEach(function() {
      embedder.registerServices();
    });
    it("renders the specified mustache template", function() {
      var template = embedder.render("youtube.com", {"video-id": "asdf"});
      expect(template.length > 0).toBeTruthy();
      expect(typeof template === "string").toBeTruthy();
    });
    it("renders the 'undefined' template if the service is not found", function() {
      var template = embedder.render("yoimmafakeservice", {host: "yo"});
      expect(template).toEqual(embedder.render("undefined", {host: "yo"}));
    });
  });

  describe("embed", function() {
    beforeEach(function() {
      spec.loadFixture("aspects_index_with_video_post");
    });
    xit("attaches embedVideo to a.video-link'", function() {
      spyOn(embedder, "embedVideo");
      $("a.video-link").click();
      expect(embedder.embedVideo).toHaveBeenCalled();
    });
    xit("shows the video when the link is clicked", function() {
      $("a.video-link").click();
      // expect video to appear! like magic!
    })
  });
});
