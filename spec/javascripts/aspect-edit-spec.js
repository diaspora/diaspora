/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("AspectEdit", function() {

  beforeEach(function() {
    spec.loadFixture('aspects_manage');
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
      expect($.fn.live.calls[0].object.selector).toEqual("#manage_aspect_zones .delete");
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
      $.proxy(AspectEdit.startDrag, $('ul .person').first())();
      expect(AspectEdit.animateImage).toHaveBeenCalled();
      expect(AspectEdit.animateImage.mostRecentCall.args[0]).toHaveClass("avatar");
    });
    it("fades in the drag and drop text", function() {
      spyOn($.fn, "fadeIn");
      $.proxy(AspectEdit.startDrag, $('ul .person').first())();
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
      $.proxy(AspectEdit.duringDrag, $('ul .person'))();
      expect($.fn.tipsy).toHaveBeenCalledWith("hide");
      expect($.fn.tipsy.mostRecentCall.object).toHaveClass("avatar");
    });
  });

  describe("stopDrag", function() {
    it("animates the image back to smaller size and full opacity", function() {
      spyOn($.fn, "animate");
      $.proxy(AspectEdit.stopDrag, $('ul .person'))();
      // fadeOut calls animate, apparently, so mostRecentCall isn't the right call
      expect($.fn.animate.calls[0].args[0]).toEqual({'height':50, 'width':50, 'opacity':1}, 200);
      expect($.fn.animate.calls[0].object).toHaveClass("avatar");
    });
    it("fades out the drag and drop text", function() {
      spyOn($.fn, "fadeOut");
      $.proxy(AspectEdit.stopDrag, $('ul .person'))();
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
        var thingToDrag = $('ul .person').last();
        var aspectId = thingToDrag.attr('data-aspect_id');
        var targetAspect = $('ul.dropzone[data-aspect_id="' + aspectId + '"]');

        spyOn($.fn, "append");
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: thingToDrag});
        expect($.fn.append).toHaveBeenCalledWith(thingToDrag);
        expect($.fn.append.mostRecentCall.object.attr("data-aspect_id")).toEqual(aspectId);
      });
    });
    describe("when moving an existing friend between aspects", function() {
      beforeEach(function() {
        thingToDrag = $('ul .person').last();
        personId = thingToDrag.attr("data-guid");
        fromAspectId = thingToDrag.attr('data-aspect_id');
        targetAspect = $('ul.dropzone').last();
        toAspectId = targetAspect.attr('data-aspect_id');
        expect(fromAspectId).not.toEqual(toAspectId);
      });
      it("calls move_contact", function() {
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: thingToDrag});
        expect($.ajax).toHaveBeenCalled();
        var args = $.ajax.mostRecentCall.args[0];
        expect(args["url"]).toEqual("/aspects/move_contact/");
        expect(args["data"]["person_id"]).toEqual(personId);
        expect(args["data"]["from"]).toEqual(fromAspectId);
        expect(args["data"]["to"]).toEqual({"to": toAspectId});
      });
      it("doesn't call the ajaxy request delete", function() {
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: thingToDrag});
        expect($.ajax.calls.length).toEqual(1);
      });
      it("adds the person to the aspect div", function() {
        spyOn($.fn, "append");
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: thingToDrag});
        expect($.fn.append).toHaveBeenCalledWith(thingToDrag);
        expect($.fn.append.mostRecentCall.object.hasClass("dropzone")).toBeTruthy();
      });
    });
    describe("when dragging a friend request", function() {
      beforeEach(function() {
        requestToDrag = $('ul .person').first();
        personId = requestToDrag.attr("data-guid");
        targetAspect = $('ul.dropzone').last();
        toAspectId = targetAspect.attr('data-aspect_id');
      });
      it("deletes the request object", function() {
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: requestToDrag});
        expect($.ajax).toHaveBeenCalled();
        var args = $.ajax.calls[0].args[0];
        expect(args["type"]).toEqual("DELETE");
        expect(args["url"]).toEqual("/requests/" + personId);
        expect(args["data"]).toEqual({"accept" : true, "aspect_id" : toAspectId });
      });
      it("doesn't call move_contact", function() {
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: requestToDrag});
        expect($.ajax.calls.length).toEqual(1);
      });
      it("adds the person to the aspect div", function() {
        spyOn($.fn, "append");
        $.proxy(AspectEdit.onDropMove, targetAspect)(null, {draggable: requestToDrag});
        expect($.fn.append).toHaveBeenCalledWith(requestToDrag);
        expect($.fn.append.mostRecentCall.object.hasClass("dropzone")).toBeTruthy();
      });
    });
  });
  
  describe("onDeleteRequestSuccess", function() {
    it("takes the request class off the person li", function() {
      var person = $('ul .person').first();
      var dropzone = $('ul.dropzone').last();
      expect(person).toHaveClass('request');
      AspectEdit.onDeleteRequestSuccess(person, dropzone);
      expect(person).not.toHaveClass('request');      
    });
    it("removes data-person_id from the li", function() {
      var person = $('ul .person').first();
      var dropzone = $('ul.dropzone').last();
      expect(person.attr("data-person_id")).toBeDefined();
      AspectEdit.onDeleteRequestSuccess(person, dropzone);
      expect(person.attr("data-person_id")).not.toBeDefined();
    });
    it("puts a data-aspect_id on the li", function() {
      var person = $('ul .person').first();
      var dropzone = $('ul.dropzone').last();
      expect(person.attr("data-aspect_id")).not.toBeDefined();
      AspectEdit.onDeleteRequestSuccess(person, dropzone);
      expect(person.attr("data-aspect_id")).toEqual(dropzone.attr("data-aspect_id"));
    });
  });

  describe("onMovePersonSuccess", function() {
    it("updates the data-aspect_id attribute on the person li", function() {
      var person = $('ul .person').last();
      var fromAspectId = person.attr('data-aspect_id');
      var dropzone = $('ul.dropzone').last();
      var toAspectId = dropzone.attr('data-aspect_id');

      expect(person.attr("data-aspect_id")).toEqual(fromAspectId);
      AspectEdit.onMovePersonSuccess(person, dropzone);
      expect(person.attr("data-aspect_id")).toEqual(toAspectId);
    });
  });

  describe("deletePersonFromAspect", function() {
    beforeEach(function() {
      spyOn($, 'ajax');
    });
    it("doesn't let you remove the person from the last aspect they're in", function() {
      spyOn(Diaspora.widgets.alert, 'alert');
      AspectEdit.deletePersonFromAspect($('li.person'));
      expect(Diaspora.widgets.alert.alert).toHaveBeenCalled();
      expect($.ajax).not.toHaveBeenCalled();
    });
  });
});
