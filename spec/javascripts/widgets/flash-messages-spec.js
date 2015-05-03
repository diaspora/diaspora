describe("Diaspora", function() {
  describe("Widgets", function() {
    describe("FlashMessages", function() {
      var flashMessages;

      describe("animateMessages", function() {
        beforeEach(function() {
          flashMessages = Diaspora.BaseWidget.instantiate("FlashMessages");
          $("#jasmine_content").html(
            '<div id="flash_notice">' +
              'flash message' +
            '</div>'
          );
        });

        it("is called when the DOM is ready", function() {
          spyOn(flashMessages, "animateMessages").and.callThrough();
          flashMessages.publish("widget/ready");
          expect(flashMessages.animateMessages).toHaveBeenCalled();
        });
      });

      describe("render", function() {
        it("creates a new div for the message and calls flashes.animateMessages", function() {
          spyOn(flashMessages, "animateMessages");
          flashMessages.render({
            success: true,
            message: "success!"
          });
	  expect($("#flash_notice").length).toEqual(1);
          expect(flashMessages.animateMessages).toHaveBeenCalled();
        });
      });
    });
  });
});
