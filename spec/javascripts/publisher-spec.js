/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Publisher", function() {

  Publisher.open = function(){ this.form().removeClass("closed"); }

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
      beforeEach(function(){
        this.func = Publisher.autocompletion.searchTermFromValue;
      });

      it("returns nothing if the cursor is before the @", function(){
        expect(this.func('not @dan grip', 2)).toBe('');
      });

      it("returns everything up to the cursor if the cursor is a word after that @", function(){
        expect(this.func('not @dan grip', 13)).toBe('dan grip');
      });

      it("returns up to the cursor if the cursor is after that @", function(){
        expect(this.func('not @dan grip', 7)).toBe('da');
      });

      it("returns everything after an @ at the start of the line", function(){
        expect(this.func('@dan grip', 9)).toBe('dan grip');
      });
      it("returns nothing if there is no @", function(){
        expect(this.func('dan', 3)).toBe('');
      });
      it("returns nothing for just an @", function(){
        expect(this.func('@', 1)).toBe('');
      });
      it("returns nothing if there are letters preceding the @", function(){
        expect(this.func('ioj@asdo', 8)).toBe('');
      });
      it("returns everything up to the cursor if there are 2 @s and the cursor is between them", function(){
        expect(this.func('@asdpo  aoisdj @asodk', 8)).toBe('asdpo');
      });
      it("returns everything from the 2nd @ up to the cursor if there are 2 @s and the cursor after them", function(){
        expect(this.func('@asod asdo @asd asok', 15)).toBe('asd');
      });
    });

    describe("mentionList", function(){
      beforeEach(function(){
        spec.loadFixture('aspects_index');

        this.list = Publisher.autocompletion.mentionList;
        this.visibleInput = Publisher.input();
        this.hiddenInput = Publisher.hiddenInput();
        this.mention = { visibleStart : 0,
          visibleEnd   : 5,
          mentionString : "@{Danny; dan@pod.org}"
        };

        this.list.mentions = [];
        this.list.push(this.mention);
        this.visibleVal = "Danny loves testing javascript";
        this.visibleInput.val(this.visibleVal);
        this.hiddenVal = "@{Danny; dan@pod.org} loves testing javascript";
        this.hiddenInput.val(this.hiddenVal);
      });

      describe("selectionDeleted", function(){
        beforeEach(function(){
          this.func = this.list.selectionDeleted;
          this.visibleVal = "Danny Daniel David Darren";
          this.visibleInput.val(this.visibleVal);
          this.list.mentions = [];
          this.danny = {
            visibleStart : 0,
            visibleEnd : 5,
            mentionString : "@{Danny; danny@pod.org}"
          };
          this.daniel = {
            visibleStart : 6,
            visibleEnd : 12,
            mentionString : "@{Daniel; daniel@pod.org}"
          };
          this.david = {
            visibleStart : 13,
            visibleEnd : 18,
            mentionString : "@{David; david@pod.org}"
          };
          this.darren = {
            visibleStart : 19,
            visibleEnd : 25,
            mentionString : "@{Darren; darren@pod.org}"
          };

          _.each([this.danny, this.daniel, this.david, this.darren], function(person){
            this.list.push(person);
          }, this);
        });

        it("destroys mentions within the selection", function(){
          this.func(4,11);
          expect(this.list.sortedMentions()).toEqual([this.darren, this.david])
        });

        it("moves remaining mentions back", function(){
          this.func(7,14);
          var length = 11 - 4;

          expect(this.danny.visibleStart).toBe(0);
          expect(this.darren.visibleStart).toBe(19-length);
        });
      });

      describe("generateHiddenInput", function(){
        it("replaces mentions in a string", function(){
          expect(this.list.generateHiddenInput(this.visibleVal)).toBe(this.hiddenVal);
        });
      });

      describe("push", function(){
        it("adds mention to mentions array", function(){
          expect(this.list.mentions.length).toBe(1);
          expect(this.list.mentions[0]).toBe(this.mention)
        });
      });

      describe("mentionAt", function(){
        it("returns the location of the mention at that location in the mentions array", function(){
          expect(this.list.mentions[this.list.mentionAt(3)]).toBe(this.mention);
        });

        it("returns null if there is no mention", function(){
          expect(this.list.mentionAt(8)).toBeFalsy();
        });
      });

      describe("insertionAt", function(){
        it("does nothing if there is no visible mention at that index", function(){
          this.list.insertionAt(8);
          expect(this.visibleInput.val()).toBe(this.visibleVal);
          expect(this.hiddenInput.val()).toBe(this.hiddenVal);
        });

        it("deletes the mention from the hidden field if there is a mention", function(){
          this.list.insertionAt(3);
          expect(this.visibleInput.val()).toBe(this.visibleVal);
          expect(this.list.generateHiddenInput(this.visibleInput.val())).toBe(this.visibleVal);
        });

        it("deletes the mention from the list", function(){
          this.list.insertionAt(3);
          expect(this.list.mentionAt(3)).toBeFalsy();
        });

        it("calls updateMentionLocations", function(){
          mentionTwo = { visibleStart : 8,
            visibleEnd   : 15,
            mentionString : "@{SomeoneElse; other@pod.org}"
          };
          this.list.push(mentionTwo);

          spyOn(this.list, 'updateMentionLocations');
          this.list.insertionAt(3,4, 60);
          expect(this.list.updateMentionLocations).toHaveBeenCalled();
        });
      });

      describe("updateMentionLocations", function(){
        it("updates the offsets of the remaining mentions in the list", function(){
          mentionTwo = { visibleStart : 8,
            visibleEnd   : 15,
            mentionString : "@{SomeoneElse; other@pod.org}"
          };
          this.list.push(mentionTwo);
          this.list.updateMentionLocations(7, 1);
          expect(mentionTwo.visibleStart).toBe(9);
          expect(mentionTwo.visibleEnd).toBe(16);
        });
      });
    });

    describe("keyUpHandler", function(){
      beforeEach(function(){
        spec.loadFixture('aspects_index');
        Publisher.initialize();
        this.input = Publisher.input();
        this.submit = Publisher.submit();
        Publisher.open();
      });

      it("keep the share button disabled when adding only whitespaces", function(){
        expect(this.submit.attr('disabled')).toBeTruthy();
        this.input.val(' ');
        this.input.keyup();
        expect(this.submit.attr('disabled')).toBeTruthy();
      });

      it("enable the share button when adding non-whitespace characters", function(){
        expect(this.submit.attr('disabled')).toBeTruthy();
        this.input.val('some text');
        this.input.keyup();
        expect(this.submit.attr('disabled')).toBeFalsy();
      });

      it("should toggle share button disable/enable when playing with input", function(){
        expect(this.submit.attr('disabled')).toBeTruthy();
        this.input.val('         ');
        this.input.keyup();
        expect(this.submit.attr('disabled')).toBeTruthy();
        this.input.val('text');
        this.input.keyup();
        this.expect(this.submit.attr('disabled')).toBeFalsy();
        this.input.val('');
        this.input.keyup();
        expect(this.submit.attr('disabled')).toBeTruthy();
      });
    });

    describe("addMentionToInput", function(){
      beforeEach(function(){
        spec.loadFixture('aspects_index');
        this.func = Publisher.autocompletion.addMentionToInput;
        this.input = Publisher.input();
        this.replaceWith = "Replace with this.";
        Publisher.autocompletion.mentionList.mentions = [];
      });

      it("replaces everything up to the cursor if the cursor is a word after that @", function(){
        this.input.val('not @dan grip');
        var cursorIndex = 13;
        this.func(this.input, cursorIndex, this.replaceWith);
        expect(this.input.val()).toBe('not ' + this.replaceWith);
      });

      it("replaces everything between @ and the cursor if the cursor is after that @", function(){
        this.input.val('not @dan grip');
        var cursorIndex = 7;
        this.func(this.input, cursorIndex, this.replaceWith);
        expect(this.input.val()).toBe('not ' + this.replaceWith + 'n grip');
      });

      it("replaces everything up to the cursor from @ at the start of the line", function(){
        this.input.val('@dan grip');
        var cursorIndex = 9;
        this.func(this.input, cursorIndex, this.replaceWith);
        expect(this.input.val()).toBe(this.replaceWith);
      });

      it("replaces everything between the first @ and the cursor if there are 2 @s and the cursor is between them", function(){
        this.input.val('@asdpo  aoisdj @asodk');
        var cursorIndex = 8;
        this.func(this.input, cursorIndex, this.replaceWith);
        expect(this.input.val()).toBe(this.replaceWith + 'aoisdj @asodk');
      });

      it("replaces everything after the 2nd @ if there are 2 @s and the cursor after them", function(){
        this.input.val('@asod asdo @asd asok');
        var cursorIndex = 15;
        this.func(this.input, cursorIndex, this.replaceWith);
        expect(this.input.val()).toBe('@asod asdo ' + this.replaceWith + ' asok');
      });
    });
  });
});
