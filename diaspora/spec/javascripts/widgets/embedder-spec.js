/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Diaspora", function() {
  describe("widgets", function() {
    describe("embedder", function() {
      describe("services", function() {
        it("is an object containing all the supported services", function() {
          expect(typeof Diaspora.widgets.embedder.services === "object").toBeTruthy();
        });
      });
      describe("register", function() {
        it("adds a service and it's template to Diaspora.widgets.embedder.services", function() {
          expect(typeof Diaspora.widgets.embedder.services["ohaibbq"] === "undefined").toBeTruthy();
          Diaspora.widgets.embedder.register("ohaibbq", "sup guys");
          expect(typeof Diaspora.widgets.embedder.services["ohaibbq"] === "undefined").toBeFalsy();
        });
      });
      describe("render", function() {
        beforeEach(function(){
          Diaspora.widgets.embedder.registerServices();
        });
        it("renders the specified mustache template", function() {
          var template = Diaspora.widgets.embedder.render("youtube.com", {"video-id": "asdf"});
          expect(template.length > 0).toBeTruthy();
          expect(typeof template === "string").toBeTruthy();
        });
        it("renders the 'undefined' template if the service is not found", function() {
          var template = Diaspora.widgets.embedder.render("yoimmafakeservice", {host: "yo"});
          expect(template).toEqual(Diaspora.widgets.embedder.render("undefined", {host: "yo"}));
        });
      });
      describe("embed", function() {
        beforeEach(function() {
          $("#jasmine_content").html(
              '<div class="stream" id="main_stream">' +
                  '<a href="#video" class="video-link" data-host="youtube.com" data-video-id="asdf">' +
                  'spec video' +
                  '</a>' +
                  '</div>'
              );
        });

        it("attaches onVideoLinkClicked to a.video-link'", function() {
          spyOn(Diaspora.widgets.embedder, "onVideoLinkClicked");
          Diaspora.widgets.embedder.publish("widget/ready");
          $("a.video-link:first").click();
          expect(Diaspora.widgets.embedder.onVideoLinkClicked).toHaveBeenCalled();
        });
      });


      it("has to have a certain DOM structure", function() {
        spec.loadFixture("aspects_index_with_posts");

        var $post = $("#main_stream").children(".stream_element:first"),
          $contentParagraph = $post.children(".sm_body").children('.content').children("p");

        expect($contentParagraph.length).toEqual(1);
      });
    });
  });
});
