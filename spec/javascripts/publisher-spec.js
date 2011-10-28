/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Publisher", function() {

  describe("initialize", function(){
    it("does not call close when there is prefilled text", function(){
      spec.loadFixture('aspects_index_prefill');
      spyOn(Publisher, 'close');
      Publisher.initialize();
      expect(Publisher.close).wasNotCalled();
    });
  });

  describe("toggleCounter", function(){
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
    });

    it("gets called in when you toggle service icons", function(){
      spyOn(Publisher, 'createCounter');
      Publisher.toggleServiceField($(".service_icon").first());
      expect(Publisher.createCounter).toHaveBeenCalled();
    });

    it("removes the .counter span", function(){
      spyOn($.fn, "remove");
      Publisher.createCounter($(".service_icon").first());
      expect($.fn.remove).toHaveBeenCalled();
    });
  });

  describe("bindAspectToggles", function() {
    beforeEach( function(){
      spec.loadFixture('status_message_new');
      Publisher.open();
    });

    it('gets called on initialize', function(){
      spyOn(Publisher, 'bindAspectToggles'); 
      Publisher.initialize();
      expect(Publisher.bindAspectToggles).toHaveBeenCalled();
    });

    it('correctly initializes an all_aspects state', function(){
      Publisher.initialize();

      expect($("#publisher .dropdown .dropdown_list li.radio").first().hasClass("selected")).toBeFalsy();
      expect($("#publisher .dropdown .dropdown_list li.radio").last().hasClass("selected")).toBeTruthy();

      $.each($("#publihser .dropdown .dropdown_list li.aspect_selector"), function(index, element){
        expect($(element).hasClass("selected")).toBeFalsy();
      });
    });

    it('toggles selected only on the clicked icon', function(){
      Publisher.initialize();

      $("#publisher .dropdown .dropdown_list li.aspect_selector").last().click();

      $.each($("#publisher .dropdown .dropdown_list li.radio"), function(index, element){
        expect($(element).hasClass("selected")).toBeFalsy();
      });

      expect($("#publisher .dropdown .dropdown_list li.aspect_selector").first().hasClass("selected")).toBeFalsy();
      expect($("#publisher .dropdown .dropdown_list li.aspect_selector").last().hasClass("selected")).toBeTruthy();
    });

    it('calls toggleAspectIds with the clicked element', function(){
      spyOn(Publisher, 'toggleAspectIds');
      Publisher.bindAspectToggles();
      var aspectBadge = $("#publisher .dropdown .dropdown_list li").last();
      aspectBadge.click();
      expect(Publisher.toggleAspectIds.mostRecentCall.args[0].get(0)).toEqual(aspectBadge.get(0));
    });
  });

  describe('toggleAspectIds', function(){
    beforeEach( function(){
      spec.loadFixture('status_message_new');
      li = $("<li data-aspect_id=42></li>");
    });

    it('adds a hidden field to the form if there is not one already', function(){
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);
      expect($('#publisher [name="aspect_ids[]"]').last().attr('value')).toBe('all_aspects');
      Publisher.toggleAspectIds(li);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);
      expect($('#publisher [name="aspect_ids[]"]').last().attr('value')).toBe('42');
    });

    it('removes the hidden field if its already there', function() {
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);

      Publisher.toggleAspectIds(li);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);

      Publisher.toggleAspectIds(li);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(0);
    });

    it('does not remove a hidden field with a different value', function() {
      var li2 = $("<li data-aspect_id=99></li>");

      Publisher.toggleAspectIds(li);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(1);

      Publisher.toggleAspectIds(li2);
      expect($('#publisher [name="aspect_ids[]"]').length).toBe(2);
    });
  });

  describe("bindServiceIcons", function() {
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
    });

    it('gets called on initialize', function(){
      spyOn(Publisher, 'bindServiceIcons');
      Publisher.initialize();
      expect(Publisher.bindServiceIcons).toHaveBeenCalled();
    });

    it('toggles dim only on the clicked icon', function(){
      expect($(".service_icon#facebook").hasClass("dim")).toBeTruthy();
      expect($(".service_icon#twitter").hasClass("dim")).toBeTruthy();

      Publisher.bindServiceIcons();
      $(".service_icon#facebook").click();

      expect($(".service_icon#facebook").hasClass("dim")).toBeFalsy();
      expect($(".service_icon#twitter").hasClass("dim")).toBeTruthy();
    });

    it('binds to the services icons and toggles the hidden field', function(){
      spyOn(Publisher, 'toggleServiceField');
      Publisher.bindServiceIcons();
      $(".service_icon#facebook").click();

      expect(Publisher.toggleServiceField).toHaveBeenCalled();
    });
  });

  describe('toggleServiceField', function(){
    beforeEach( function(){
      spec.loadFixture('aspects_index_services');
    });

    it('adds a hidden field to the form if there is not one already', function(){
      expect($('#publisher [name="services[]"]').length).toBe(0);
      Publisher.toggleServiceField($(".service_icon#facebook").first());
      expect($('#publisher [name="services[]"]').length).toBe(1);
      expect($('#publisher [name="services[]"]').attr('value')).toBe("facebook");
    });

    it('removes the hidden field if its already there', function() {
      Publisher.toggleServiceField($(".service_icon#facebook").first());
      expect($('#publisher [name="services[]"]').length).toBe(1);

      Publisher.toggleServiceField($(".service_icon#facebook").first());
      expect($('#publisher [name="services[]"]').length).toBe(0);
    });

    it('does not remove a hidden field with a different value', function() {
      Publisher.toggleServiceField($(".service_icon#facebook").first());
      expect($('#publisher [name="services[]"]').length).toBe(1);

      Publisher.toggleServiceField($(".service_icon#twitter").first());
      expect($('#publisher [name="services[]"]').length).toBe(2);
    });
  });

  describe("open", function() {
    beforeEach(function() {
      spec.loadFixture('aspects_index');
      Publisher.initialize();
    });
    it("removes the closed class", function() {
      expect(Publisher.form().hasClass('closed')).toBeTruthy();
      Publisher.open();
      expect(Publisher.form().hasClass('closed')).toBeFalsy();
    });
    it("disables the share button", function() {
      expect(Publisher.submit().attr('disabled')).toBeFalsy();
      Publisher.open();
      expect(Publisher.submit().attr('disabled')).toBeTruthy();
    });
  });
  describe("close", function() {
    beforeEach(function() {
      spec.loadFixture('aspects_index_prefill');
      Publisher.initialize();
    });
    it("adds the closed class", function() {
      Publisher.form().removeClass('closed');
      expect(Publisher.form().hasClass('closed')).toBeFalsy();
      Publisher.close();
      expect(Publisher.form().hasClass('closed')).toBeTruthy();
    });
  });
  describe("input", function(){
    beforeEach(function(){
      spec.loadFixture('aspects_index_prefill');
    });
    it("returns the status_message_fake_text textarea", function(){
      expect(Publisher.input()[0].id).toBe('status_message_fake_text');
      expect(Publisher.input().length).toBe(1);
    });
  });
  describe("autocompletion", function(){
    describe("searchTermFromValue", function(){
      var func;
      beforeEach(function(){func = Publisher.autocompletion.searchTermFromValue;});
      it("returns nothing if the cursor is before the @", function(){
        expect(func('not @dan grip', 2)).toBe('');
      });
      it("returns everything up to the cursor if the cursor is a word after that @", function(){
        expect(func('not @dan grip', 13)).toBe('dan grip');
      });
      it("returns up to the cursor if the cursor is after that @", function(){
        expect(func('not @dan grip', 7)).toBe('da');
      });

      it("returns everything after an @ at the start of the line", function(){
        expect(func('@dan grip', 9)).toBe('dan grip');
      });
      it("returns nothing if there is no @", function(){
        expect(func('dan', 3)).toBe('');
      });
      it("returns nothing for just an @", function(){
        expect(func('@', 1)).toBe('');
      });
      it("returns nothing if there are letters preceding the @", function(){
        expect(func('ioj@asdo', 8)).toBe('');
      });
      it("returns everything up to the cursor if there are 2 @s and the cursor is between them", function(){
        expect(func('@asdpo  aoisdj @asodk', 8)).toBe('asdpo');
      });
      it("returns everything from the 2nd @ up to the cursor if there are 2 @s and the cursor after them", function(){
        expect(func('@asod asdo @asd asok', 15)).toBe('asd');
      });
    });

    describe("onSelect", function(){

    });

    describe("mentionList", function(){
      var visibleInput, visibleVal,
      hiddenInput, hiddenVal,
      list,
      mention;
      beforeEach(function(){
        spec.loadFixture('aspects_index');
        list = Publisher.autocompletion.mentionList;
        visibleInput = Publisher.input();
        hiddenInput = Publisher.hiddenInput();
        mention = { visibleStart : 0,
          visibleEnd   : 5,
          mentionString : "@{Danny; dan@pod.org}"
        };
        list.mentions = [];
        list.push(mention);
        visibleVal = "Danny loves testing javascript";
        visibleInput.val(visibleVal);
        hiddenVal = "@{Danny; dan@pod.org} loves testing javascript";
        hiddenInput.val(hiddenVal);
      });
      describe("selectionDeleted", function(){
        var func, danny, daniel, david, darren;
        beforeEach(function(){
          func = list.selectionDeleted;
          visibleVal = "Danny Daniel David Darren";
          visibleInput.val(visibleVal);
          list.mentions = [];
          danny = {
            visibleStart : 0,
            visibleEnd : 5,
            mentionString : "@{Danny; danny@pod.org}"
          };
          daniel = {
            visibleStart : 6,
            visibleEnd : 12,
            mentionString : "@{Daniel; daniel@pod.org}"
          };
          david = {
            visibleStart : 13,
            visibleEnd : 18,
            mentionString : "@{David; david@pod.org}"
          };
          darren = {
            visibleStart : 19,
            visibleEnd : 25,
            mentionString : "@{Darren; darren@pod.org}"
          };
          list.push(danny)
          list.push(daniel)
          list.push(david)
          list.push(darren)
        });
        it("destroys mentions within the selection", function(){
          func(4,11);
          expect(list.sortedMentions()).toEqual([darren, david])
        });
        it("moves remaining mentions back", function(){
          func(7,14);
          var length = 11 - 4
          expect(danny.visibleStart).toBe(0);
          expect(darren.visibleStart).toBe(19-length);
        });
      });
      describe("generateHiddenInput", function(){
        it("replaces mentions in a string", function(){
          expect(list.generateHiddenInput(visibleVal)).toBe(hiddenVal);
        });
      });
      describe("push", function(){
        it("adds mention to mentions array", function(){
          expect(list.mentions.length).toBe(1);
          expect(list.mentions[0]).toBe(mention)
        });
      });
      describe("mentionAt", function(){
        it("returns the location of the mention at that location in the mentions array", function(){
          expect(list.mentions[list.mentionAt(3)]).toBe(mention);
        });
        it("returns null if there is no mention", function(){
          expect(list.mentionAt(8)).toBeFalsy();
        });
      });
      describe("insertionAt", function(){
        it("does nothing if there is no visible mention at that index", function(){
          list.insertionAt(8);
          expect(visibleInput.val()).toBe(visibleVal);
          expect(hiddenInput.val()).toBe(hiddenVal);
        });
        it("deletes the mention from the hidden field if there is a mention", function(){
          list.insertionAt(3);
          expect(visibleInput.val()).toBe(visibleVal);
          expect(list.generateHiddenInput(visibleInput.val())).toBe(visibleVal);
        });
        it("deletes the mention from the list", function(){
          list.insertionAt(3);
          expect(list.mentionAt(3)).toBeFalsy();
        });
        it("calls updateMentionLocations", function(){
          mentionTwo = { visibleStart : 8,
            visibleEnd   : 15,
            mentionString : "@{SomeoneElse; other@pod.org}"
          };
          list.push(mentionTwo);
          spyOn(list, 'updateMentionLocations');
          list.insertionAt(3,4, 60);
          expect(list.updateMentionLocations).toHaveBeenCalled();
        });
      });
      describe("updateMentionLocations", function(){
        it("updates the offsets of the remaining mentions in the list", function(){
          mentionTwo = { visibleStart : 8,
            visibleEnd   : 15,
            mentionString : "@{SomeoneElse; other@pod.org}"
          };
          list.push(mentionTwo);
          list.updateMentionLocations(7, 1);
          expect(mentionTwo.visibleStart).toBe(9);
          expect(mentionTwo.visibleEnd).toBe(16);
        });
      });
    });

    describe("keyUpHandler", function(){
      var input;
      var submit;
      beforeEach(function(){
        spec.loadFixture('aspects_index');
        Publisher.initialize();
        input = Publisher.input();
        submit = Publisher.submit();
        Publisher.open();
      });
      it("keep the share button disabled when adding only whitespaces", function(){
        expect(submit.attr('disabled')).toBeTruthy();
        input.val(' ');
        input.keyup();
        expect(submit.attr('disabled')).toBeTruthy();
      });
      it("enable the share button when adding non-whitespace characters", function(){
        expect(submit.attr('disabled')).toBeTruthy();
        input.val('some text');
        input.keyup();
        expect(submit.attr('disabled')).toBeFalsy();
      });
      it("should toggle share button disable/enable when playing with input", function(){
        expect(submit.attr('disabled')).toBeTruthy();
        input.val('         ');
        input.keyup();
        expect(submit.attr('disabled')).toBeTruthy();
        input.val('text');
        input.keyup();
        expect(submit.attr('disabled')).toBeFalsy();
        input.val('');
        input.keyup();
        expect(submit.attr('disabled')).toBeTruthy();
      });
    });

    describe("addMentionToInput", function(){
      var func;
      var input;
      var replaceWith;
      beforeEach(function(){
        spec.loadFixture('aspects_index');
        func = Publisher.autocompletion.addMentionToInput;
        input = Publisher.input();
        Publisher.autocompletion.mentionList.mentions = [];
        replaceWith = "Replace with this.";
      });
      it("replaces everything up to the cursor if the cursor is a word after that @", function(){
        input.val('not @dan grip');
        var cursorIndex = 13;
        func(input, cursorIndex, replaceWith);
        expect(input.val()).toBe('not ' + replaceWith);
      });
      it("replaces everything between @ and the cursor if the cursor is after that @", function(){
        input.val('not @dan grip');
        var cursorIndex = 7;
        func(input, cursorIndex, replaceWith);
        expect(input.val()).toBe('not ' + replaceWith + 'n grip');
      });
      it("replaces everything up to the cursor from @ at the start of the line", function(){
        input.val('@dan grip');
        var cursorIndex = 9;
        func(input, cursorIndex, replaceWith);
        expect(input.val()).toBe(replaceWith);
      });
      it("replaces everything between the first @ and the cursor if there are 2 @s and the cursor is between them", function(){
        input.val('@asdpo  aoisdj @asodk');
        var cursorIndex = 8;
        func(input, cursorIndex, replaceWith);
        expect(input.val()).toBe(replaceWith + 'aoisdj @asodk');
      });
      it("replaces everything after the 2nd @ if there are 2 @s and the cursor after them", function(){
        input.val('@asod asdo @asd asok');
        var cursorIndex = 15;
        func(input, cursorIndex, replaceWith);
        expect(input.val()).toBe('@asod asdo ' + replaceWith + ' asok');
      });
    });
  });
});
