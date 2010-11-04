describe("AspectEdit", function() {

  describe("initialize", function() {
    it("calls draggable on ul .person", function() {
      spyOn($.fn, "draggable");
      AspectEdit.initialize();
      expect($.fn.draggable).toHaveBeenCalledWith(
        {revert: true, start: AspectEdit.startDrag,
         drag: AspectEdit.duringDrag, stop: AspectEdit.stopDrag});
      expect($.fn.draggable.mostRecentCall.object.selector).toEqual("ul .person");
    });
    it("calls droppable on .aspect ul.dropzone", function() {
      spyOn($.fn, "droppable");
      AspectEdit.initialize();
      expect($.fn.droppable).toHaveBeenCalledWith({hoverClass: 'active', drop: AspectEdit.onDropMove});
      expect($.fn.droppable.calls[0].object.selector).toEqual(".aspect ul.dropzone");
// This would be AWESOME:
//      expect($.fn.droppable)
//        .toHaveBeenCalled()
//          .on(".aspect ul.dropzone")
//          .with({});
    });
  });

  describe("startDrag", function() {
    it("animates the image", function() {
      $('#jasmine_content').html('<ul><li class="person ui-draggable" data-aspect_id="4cae42e12367bca44e000005" data-guid="4cae42d32367bca44e000003" style="top: 0px; left: 0px; ">' +
                  '<img alt="Alexander Hamiltom" class="avatar" data-person_id="4cae42d32367bca44e000003" src="/images/user/default.png?1287542906" original-title="Alexander Hamiltom" style="height: 70px; width: 70px; opacity: 1; display: inline; ">' +
                '</li></ul>');
      spyOn(AspectEdit, "animateImage");
      $.proxy(AspectEdit.startDrag, $('.person.ui-draggable'))();
      expect(AspectEdit.animateImage).toHaveBeenCalled();
      expect(AspectEdit.animateImage.mostRecentCall.args[0]).toHaveClass("avatar");
    });
  });

  describe("decrementRequestsCounter", function() {
    describe("when there is one request", function() {
      it("removes the counter from the new requests div", function() {
        $('#jasmine_content').html("<div class='new_requests'>Requests (1)</div>");
        AspectEdit.decrementRequestsCounter();
        expect($('.new_requests').first().html()).toEqual("Requests");
      });
    });
    describe("when there is more than one request", function() {
      it("decrements the request counter", function() {
        $('#jasmine_content').html("<div class='new_requests'>Requests (67)</div>");
        AspectEdit.decrementRequestsCounter();
        expect($('.new_requests').first().html()).toEqual("Requests (66)");
      });
    });
    describe("error cases", function() {
      it("fails silently if there are no requests", function() {
        $('#jasmine_content').html("<div class='new_requests'>Requests</div>");
        AspectEdit.decrementRequestsCounter();
        expect($('.new_requests').first().html()).toEqual("Requests");
      });
    });
  });
});