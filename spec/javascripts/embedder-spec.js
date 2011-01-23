/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
describe("Embedder", function() {
  describe("services", function() {
    it("is an object containing all the supported services", function() {
      expect(typeof Embedder.services === "object").toBeTruthy();
    });
  });
  describe("register", function() {
    it("adds a service and it's template to Embedder.services", function() {
      expect(typeof Embedder.services["ohaibbq"] === "undefined").toBeTruthy();
      Embedder.register("ohaibbq", "sup guys");
      expect(typeof Embedder.services["ohaibbq"] === "undefined").toBeFalsy();
    });
  });
  describe("render", function() {
    it("renders the specified mustache template", function() {
      var template = Embedder.render("youtube.com", {"video-id": "asdf"});
      expect(template.length > 0).toBeTruthy();
      expect(typeof template === "string").toBeTruthy();
    });
    it("renders the 'undefined' template if the service is not found", function() {
      var template = Embedder.render("yoimmafakeservice", {host: "yo"});
      expect(template).toEqual(Embedder.render("undefined", {host: "yo"}));
    });
  });
  describe("embed", function() {
    beforeEach(function() {
      $("#jasmine_content").html(
        '<div class="stream">' +
          '<a href="#video" class="video-link" data-host="youtube.com" data-video-id="asdf">' +
            'spec video' +
          '</a>' +
        '</div>'
      );
    });

    it("delegates '.stream a.video-link'", function() {
      spyOn($.fn, "delegate");
      Embedder.initialize();
      expect($.fn.delegate).toHaveBeenCalledWith("a.video-link", "click", Embedder.onVideoLinkClick);
    });
  });
});