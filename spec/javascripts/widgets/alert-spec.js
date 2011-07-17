describe("Diaspora", function() {
  describe("widgets", function() {
    describe("alert", function() {
      beforeEach(function() {
	$(document).trigger("close.facebox");
      });

      describe("on widget ready", function() {
	it("should attach an event which will close detach the element from the DOM to close.facebox", function() {
	  Diaspora.widgets.alert.alert("YEAH", "YEAHH");
	  expect($("#diaspora_alert").length).toEqual(1);
	  $(document).trigger("close.facebox");
	  expect($("#diaspora_alert").length).toEqual(0);
	});

      });
      describe("alert", function() {
	it("should render a mustache template and append it the body", function() {
	  Diaspora.widgets.alert.alert("YO", "YEAH");
	  expect($("#diaspora_alert").length).toEqual(1);
	  $(document).trigger("close.facebox");
	});
      });
    });
  }); 
});
