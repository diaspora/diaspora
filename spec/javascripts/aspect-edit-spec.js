describe("editing aspects", function() {

  describe("decrementRequestsCounter", function() {
    describe("when there is one request", function() {
      it("removes the counter from the new requests div", function() {
        $('#jasmine_content').html("<div class='new_requests'>Requests (1)</div>");
        decrementRequestsCounter();
        expect($('.new_requests').first().html()).toEqual("Requests");
      });
    });
    describe("when there is more than one request", function() {
      it("decrements the request counter", function() {
        $('#jasmine_content').html("<div class='new_requests'>Requests (67)</div>");
        decrementRequestsCounter();
        expect($('.new_requests').first().html()).toEqual("Requests (66)");
      });
    });
    describe("error cases", function() {
      it("fails silently if there are no requests", function() {
        $('#jasmine_content').html("<div class='new_requests'>Requests</div>");
        decrementRequestsCounter();
        expect($('.new_requests').first().html()).toEqual("Requests");
      });
    });
  });

});