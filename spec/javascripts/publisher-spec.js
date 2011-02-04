/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Publisher", function() {

    describe("initialize", function(){
      it("calls updateHiddenField", function(){
        spec.loadFixture('aspects_index_prefill');
        spyOn(Publisher, 'updateHiddenField');
        Publisher.initialize();
        expect(Publisher.updateHiddenField).toHaveBeenCalled();
      });

      it("attaches updateHiddenField to the keydown handler on fake_message", function(){
        spec.loadFixture('aspects_index_prefill');
        spyOn(Publisher, 'updateHiddenField');
        Publisher.initialize();
        Publisher.form().find('#status_message_fake_message').keydown();
        expect(Publisher.updateHiddenField.mostRecentCall.args[0].type).toBe('keydown');
      });

      it("calls close when it does not have text", function(){
        spec.loadFixture('aspects_index');
        spyOn(Publisher, 'close');
        Publisher.initialize();
        expect(Publisher.close).toHaveBeenCalled();
      });

      it("does not call close when there is prefilled text", function(){
        spec.loadFixture('aspects_index_prefill');
        spyOn(Publisher, 'close');
        Publisher.initialize();
        expect(Publisher.close).wasNotCalled();
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
      it("shows the options_and_submit div", function() {
        expect(Publisher.form().find(".options_and_submit:visible").length).toBe(0);
        Publisher.open();
        expect(Publisher.form().find(".options_and_submit:visible").length).toBe(1);
        });
    });
    describe("close", function() {
      beforeEach(function() {
        spec.loadFixture('aspects_index_prefill');
        Publisher.initialize();
        });
      it("adds the closed class", function() {
        expect(Publisher.form().hasClass('closed')).toBeFalsy();
        Publisher.close();
        expect(Publisher.form().hasClass('closed')).toBeTruthy();
        });
      it("hides the options_and_submit div", function() {
        expect(Publisher.form().find(".options_and_submit:visible").length).toBe(1);
        Publisher.close();
        expect(Publisher.form().find(".options_and_submit:visible").length).toBe(0);
        });
    });
    describe("updateHiddenField", function(){
      beforeEach(function(){
        spec.loadFixture('aspects_index_prefill');
      });

      it("copies the value of fake_message to message",function(){
        Publisher.updateHiddenField();
        expect(Publisher.form().find('#status_message_message').val()).toBe(
          Publisher.form().find('#status_message_fake_message').val());
      });
    });
    describe("input", function(){
      beforeEach(function(){
        spec.loadFixture('aspects_index_prefill');
      });
      it("returns the status_message_fake_message textarea", function(){
        expect(Publisher.input()[0].id).toBe('status_message_fake_message');
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
        it("returns everything after an @ if the cursor is a word after that @", function(){
          expect(func('not @dan grip', 13)).toBe('dan grip');
        });
        it("returns everything after an @ if the cursor is after that @", function(){
          expect(func('not @dan grip', 7)).toBe('dan grip');
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
        it("returns everything between @s if there are 2 @s and the cursor is between them", function(){
          expect(func('@asdpo  aoisdj @asodk', 8)).toBe('asdpo  aoisdj');
        });
        it("returns everything after the 2nd @ if there are 2 @s and the cursor after them", function(){
          expect(func('@asod asdo @asd asok', 15)).toBe('asd asok');
        });
      });

      describe("onSelect", function(){

      });
      describe("addMentionToHiddenInput", function(){
        var func;
        var input;

        beforeEach(function(){
          spec.loadFixture('aspects_index');
          func = Publisher.autocompletion.addMentionToHiddenInput;
          input = Publisher.input();
        });

      });

      describe("addMentionToVisibleInput", function(){
        var func;
        var input;
        var replaceWith;
        beforeEach(function(){
          spec.loadFixture('aspects_index');
          func = Publisher.autocompletion.addMentionToVisibleInput;
          input = Publisher.input();
          replaceWith = "Replace with this.";
        });
        it("replaces everything after an @ if the cursor is a word after that @", function(){
          input.val('not @dan grip');
          func(input,  replaceWith);
          input[0].selectionStart = 13;
          expect(input.val()).toBe('not ' + replaceWith);
        });
        it("replaces everything after an @ if the cursor is after that @", function(){
          input.val('not @dan grip');
          input[0].selectionStart = 7;
          func(input,  replaceWith);
          expect(input.val()).toBe('not ' + replaceWith);
        });
        it("replaces everything after an @ at the start of the line", function(){
          input.val('@dan grip');
          input[0].selectionStart = 9;
          func(input,  replaceWith);
          expect(input.val()).toBe(replaceWith);
        });
        it("replaces everything between @s if there are 2 @s and the cursor is between them", function(){
          input.val('@asdpo  aoisdj @asodk');
          input[0].selectionStart = 8;
          func(input,  replaceWith);
          expect(input.val()).toBe(replaceWith + ' @asodk');
        });
        it("replaces everything after the 2nd @ if there are 2 @s and the cursor after them", function(){
          input.val('@asod asdo @asd asok');
          input[0].selectionStart = 15;
          func(input,  replaceWith);
          expect(input.val()).toBe('@asod asdo ' + replaceWith);
        });
      });
    });
});
