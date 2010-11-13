describe("AspectEdit", function() {

  beforeEach(function() {
    $('#jasmine_content').html(
'<ul data-aspect_id="guid-of-current-aspect" class="dropzone ui-droppable">' +
'  <li class="person ui-draggable" data-aspect_id="guid-of-current-aspect" data-guid="guid-of-this-person">' +
'    <img alt="Alexander Hamiltom" class="avatar" data-person_id="guid-of-this-person" src="default.png" original-title="Alexander Hamiltom">' +
'  </li>' +
'</ul>' +
'<ul data-aspect_id="guid-of-target-aspect" class="dropzone ui-droppable">' +
'</ul>'
    );
  });

  describe("initialize", function() {
    it("calls draggable on ul .person", function() {
      spyOn($.fn, "draggable");
      AspectEdit.initialize();
      expect($.fn.draggable).toHaveBeenCalledWith({
        revert: true, 
        start: AspectEdit.startDrag,
        drag: AspectEdit.duringDrag, 
        stop: AspectEdit.stopDrag
      });
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
    it("hides the tipsy ... thingy, whatever that is", function() {
      spyOn($.fn, "tipsy");
      AspectEdit.animateImage($('.avatar'));
      expect($.fn.tipsy).toHaveBeenCalledWith("hide");
    });
    it("animates the image to make it look larger and slightly opaque", function() {
      spyOn($.fn, "animate");
      AspectEdit.animateImage($('.avatar'));
      expect($.fn.animate).toHaveBeenCalledWith({'height':80, 'width':80, 'opacity':0.8}, 200);
      expect($.fn.animate.mostRecentCall.object).toHaveClass("avatar");
    });
  });

  describe("duringDrag", function() {
    it("rehides the tipsy thingy", function() {
      spyOn($.fn, "tipsy");
      $.proxy(AspectEdit.duringDrag, $('.person.ui-draggable'))();
      expect($.fn.tipsy).toHaveBeenCalledWith("hide");
      expect($.fn.tipsy.mostRecentCall.object).toHaveClass("avatar");
    });
  });

  describe("stopDrag", function() {
    it("animates the image back to smaller size and full opacity", function() {
      spyOn($.fn, "animate");
      $.proxy(AspectEdit.stopDrag, $('.person.ui-draggable'))();
      expect($.fn.animate).toHaveBeenCalledWith({'height':70, 'width':70, 'opacity':1}, 200);
      // fadeOut calls animate, apparently, so mostRecentCall isn't the right call
      expect($.fn.animate.calls[0].object).toHaveClass("avatar");
    });
    it("fades out the drag and drop text", function() {
      spyOn($.fn, "fadeOut");
      $.proxy(AspectEdit.stopDrag, $('.person.ui-draggable'))();
      expect($.fn.fadeOut).toHaveBeenCalledWith(100);
      expect($.fn.fadeOut.mostRecentCall.object.selector).toEqual(".draggable_info");
    });
  });

  describe("onDropMove", function() {
    beforeEach(function() {
      spyOn($, "ajax");
    });
    describe("when you drop the friend or request onto the div you dragged it from", function() {
      it("doesn't call any ajax stuffs", function() {
        var targetAspect = $('.dropzone.ui-droppable[data-aspect_id="guid-of-current-aspect"]');
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: $('.person.ui-draggable')});
        expect($.ajax).not.toHaveBeenCalled();
      });
      it("adds the person back into the original div", function() {
        var targetAspect = $('.dropzone.ui-droppable[data-aspect_id="guid-of-current-aspect"]');
        spyOn($.fn, "append");
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: $('.person.ui-draggable')});
        expect($.fn.append).toHaveBeenCalledWith($('.person.ui-draggable'));
        expect($.fn.append.mostRecentCall.object.attr("data-aspect_id")).toEqual("guid-of-current-aspect");
      });
    });
    describe("when moving an existing friend between aspects", function() {
      it("calls move_contact", function() {
        var targetAspect = $('.dropzone.ui-droppable[data-aspect_id="guid-of-target-aspect"]');
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: $('.person.ui-draggable')});
        expect($.ajax).toHaveBeenCalled();
        var args = $.ajax.mostRecentCall.args[0];
        expect(args["url"]).toEqual("/aspects/move_contact/");
        expect(args["data"]["person_id"]).toEqual("guid-of-this-person");
        expect(args["data"]["from"]).toEqual("guid-of-current-aspect");
        expect(args["data"]["to"]).toEqual({"to": "guid-of-target-aspect" });
      });
      it("doesn't call the ajaxy request delete", function() {
        var targetAspect = $('.dropzone.ui-droppable[data-aspect_id="guid-of-target-aspect"]');
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: $('.person.ui-draggable')});
        expect($.ajax.calls.length).toEqual(1);
      });
      it("adds the person to the aspect div", function() {
        var targetAspect = $('.dropzone.ui-droppable[data-aspect_id="guid-of-target-aspect"]');
        spyOn($.fn, "append");
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: $('.person.ui-draggable')});
        expect($.fn.append).toHaveBeenCalledWith($('.person.ui-draggable'));
        expect($.fn.append.mostRecentCall.object.hasClass("dropzone")).toBeTruthy();
      });
    });
    describe("when dragging a friend request", function() {
      beforeEach(function() {
        $('#jasmine_content').html(
'<li class="person request ui-draggable" data-person_id="guid-of-friendship-requestor" data-guid="guid-of-friendship-requestor">' +
'  <img alt="Alexander Hamiltom" class="avatar" data-person_id="guid-of-friendship-requestor" src="/images/user/default.png?1287542906" original-title="Alexander Hamiltom">' +
'</li>' +
'<ul data-aspect_id="guid-of-target-aspect" class="dropzone ui-droppable">' +
'</ul>'
        );
      });    
      it("deletes the request object", function() {
        $.proxy(AspectEdit.onDropMove, $('.dropzone.ui-droppable'))(null, {draggable: $('.person.ui-draggable')});
        expect($.ajax).toHaveBeenCalled();
        var args = $.ajax.calls[0].args[0];
        expect(args["type"]).toEqual("DELETE");
        expect(args["url"]).toEqual("/requests/guid-of-friendship-requestor");
        expect(args["data"]).toEqual({"accept" : true, "aspect_id" : "guid-of-target-aspect" });
      });
      it("doesn't call move_contact", function() {
        $.proxy(AspectEdit.onDropMove, $('.dropzone.ui-droppable'))(null, {draggable: $('.person.ui-draggable')});
        expect($.ajax.calls.length).toEqual(1);
      });
      it("adds the person to the aspect div", function() {
        spyOn($.fn, "append");
        $.proxy(AspectEdit.onDropMove, $('.dropzone.ui-droppable'))(null, {draggable: $('.person.ui-draggable')});
        expect($.fn.append).toHaveBeenCalledWith($('.person.ui-draggable'));
        expect($.fn.append.mostRecentCall.object.hasClass("dropzone")).toBeTruthy();
      });
    });
  });
  
  describe("onDeleteRequestSuccess", function() {
    beforeEach(function() {
      $('#jasmine_content').html(
'<li class="person request ui-draggable" data-person_id="guid-of-friendship-requestor" data-guid="guid-of-friendship-requestor">' +
'  <img alt="Alexander Hamiltom" class="avatar" data-person_id="guid-of-friendship-requestor" src="/images/user/default.png?1287542906" original-title="Alexander Hamiltom">' +
'</li>' +
'<ul data-aspect_id="guid-of-target-aspect" class="dropzone ui-droppable">' +
'</ul>' +
'<div class="new_requests">Requests (1)</div>'
      );
    });    
    it("decrements the request counter", function() {
      spyOn(AspectEdit, "decrementRequestsCounter");
      AspectEdit.onDeleteRequestSuccess($('li.person'));
      expect(AspectEdit.decrementRequestsCounter).toHaveBeenCalled();
    });
    it("takes the request class off the person li", function() {
      expect($('li.person')).toHaveClass('request');      
      AspectEdit.onDeleteRequestSuccess($('li.person'));
      expect($('li.person')).not.toHaveClass('request');      
    });
  });

  describe("onMovePersonSuccess", function() {
    it("updates the data-aspect_id attribute on the person li", function() {
      var person = $('li.person');
      var dropzone = $('.dropzone.ui-droppable[data-aspect_id="guid-of-target-aspect"]');
      expect(person.attr("data-aspect_id")).toEqual("guid-of-current-aspect");
      AspectEdit.onMovePersonSuccess(person, dropzone);
      expect(person.attr("data-aspect_id")).toEqual("guid-of-target-aspect");
    });
  });

  describe("deletePersonFromAspect", function() {
    beforeEach(function() {
      spyOn($, 'ajax');
    });
    it("doesn't let you remove the person from the last aspect they're in", function() {
      spyOn(AspectEdit, 'alertUser');
      AspectEdit.deletePersonFromAspect($('li.person'));
      expect(AspectEdit.alertUser).toHaveBeenCalled();
      expect($.ajax).not.toHaveBeenCalled();
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
