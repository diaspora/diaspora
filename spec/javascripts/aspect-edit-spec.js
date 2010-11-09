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
    });
    it("sets up the click event on .delete", function() {
      spyOn($.fn, "live");
      AspectEdit.initialize();
      expect($.fn.live).toHaveBeenCalledWith("click", AspectEdit.deletePerson);
      expect($.fn.live.calls[0].object.selector).toEqual(".delete");
    });
    it("sets up the focus event on aspect name", function() {
      spyOn($.fn, "live");
      AspectEdit.initialize();
      expect($.fn.live).toHaveBeenCalledWith('focus', AspectEdit.changeName);
      expect($.fn.live.calls[1].object.selector).toEqual(".aspect h3");
    })
  });

  describe("startDrag", function() {
    beforeEach(function() {
      $('#jasmine_content').html(
'<li class="person ui-draggable" data-aspect_id="4cae42e12367bca44e000005" data-guid="4cae42d32367bca44e000003" style="top: 0px; left: 0px; ">' +
'  <img alt="Alexander Hamiltom" class="avatar" data-person_id="4cae42d32367bca44e000003" src="/images/user/default.png?1287542906" original-title="Alexander Hamiltom" style="height: 70px; width: 70px; opacity: 1; display: inline; ">' +
'</li>'
        );
    });
    it("animates the image", function() {
      spyOn(AspectEdit, "animateImage");
      $.proxy(AspectEdit.startDrag, $('.person.ui-draggable'))();
      expect(AspectEdit.animateImage).toHaveBeenCalled();
      expect(AspectEdit.animateImage.mostRecentCall.args[0]).toHaveClass("avatar");
    });
    it("fades in the drag and drop text", function() {
      spyOn($.fn, "fadeIn");
      $.proxy(AspectEdit.startDrag, $('.person.ui-draggable'))();
      expect($.fn.fadeIn).toHaveBeenCalledWith(100);
      expect($.fn.fadeIn.mostRecentCall.object.selector).toEqual(".draggable_info");
    });
  });

  describe("animateImage", function() {
    beforeEach(function() {
      $('#jasmine_content').html(
'<li class="person ui-draggable" data-aspect_id="4cae42e12367bca44e000005" data-guid="4cae42d32367bca44e000003" style="top: 0px; left: 0px; ">' +
'  <img alt="Alexander Hamiltom" class="avatar" data-person_id="4cae42d32367bca44e000003" src="/images/user/default.png?1287542906" original-title="Alexander Hamiltom" style="height: 70px; width: 70px; opacity: 1; display: inline; ">' +
'</li>'
        );
    });
    it("hides the tipsy ... thingy, whatever that is", function() {
      spyOn($.fn, "tipsy");
      AspectEdit.animateImage($('.avatar'));
      expect($.fn.tipsy).toHaveBeenCalledWith("hide");
    });
    it("animates the image to make it look larger and slightly opaque", function() {
      spyOn($.fn, "animate");
      AspectEdit.animateImage($('.avatar'));
      expect($.fn.animate).toHaveBeenCalledWith({'height':80, 'width':80, 'opacity':0.8}, 200);
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