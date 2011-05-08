describe("Diaspora", function() {
  describe("widgets", function() {
    describe("flashes", function() {
      describe("animateMessages", function() {
        beforeEach(function() {
          $("#jasmine_content").html(
            '<div id="flash_notice">' +
              'flash message' +
            '</div>'
          );
        });

        it("is called when the DOM is ready", function() {
          spyOn(Diaspora.widgets.flashes, "animateMessages").andCallThrough();
          Diaspora.widgets.flashes.start();
          expect(Diaspora.widgets.flashes.animateMessages).toHaveBeenCalled();
        });
      });

      describe("render", function() {
        it("creates a new div for the message and calls flashes.animateMessages", function() {
          spyOn(Diaspora.widgets.flashes, "animateMessages");
          Diaspora.widgets.flashes.render({
            success: true,
            message: "success!"
          });
          expect(Diaspora.widgets.flashes.animateMessages).toHaveBeenCalled();
        });
      });
    });
  });
});