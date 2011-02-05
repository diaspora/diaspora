/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Publisher", function() {

    describe("initialize", function(){
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
      describe("onKeypress", function(){
      });,
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

      describe("mentionList", function(){
        var visibleInput, visibleVal,
            hiddenInput, hiddenVal,
            list,
            func,
            mention;
        beforeEach(function(){
          spec.loadFixture('aspects_index');
          list = Publisher.autocompletion.mentionList;
          func = list.keypressAt;
          visibleInput = Publisher.input();
          hiddenInput = Publisher.hiddenInput();
          mention = { visibleStart : 0,
                      visibleEnd   : 5,
                      hiddenStart  : 0,
                      hiddenEnd    : 21
                    };
          list.mentions = [];
          list.push(mention);
          visibleVal = "Danny loves testing javascript";
          visibleInput.val(visibleVal);
          hiddenVal = "@{Danny; dan@pod.org} loves testing javascript";
          hiddenInput.val(hiddenVal);
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
        describe("keypressAt", function(){
          it("does nothing if there is no visible mention at that index", function(){
            list.keypressAt(8);
            expect(visibleInput.val()).toBe(visibleVal)
            expect(hiddenInput.val()).toBe(hiddenVal)
          });
          it("deletes the mention from the hidden field if there is a mention", function(){
            list.keypressAt(3);
            expect(visibleInput.val()).toBe(visibleVal)
            expect(hiddenInput.val()).toBe(visibleVal)
          });
          it("deletes the mention from the list", function(){
            list.keypressAt(3);
            expect(list.mentionAt(3)).toBeFalsy();
          });
          it("updates the offsets of the remaining mentions in the list");
        });
        describe("offsetFrom", function(){
          var func;
          beforeEach(function(){
            func = list.offsetFrom;
          });
          it("returns the offset of the mention at that location", function(){
            expect(list.offsetFrom(3)).toBe(mention.offset);
          });
          it("returns the offset of the previous mention if there is no mention there", function(){
            expect(list.offsetFrom(10)).toBe(mention.offset);
          });
          it("returns 0 if there are no mentions", function(){
            list.mentions = [];
            expect(list.offsetFrom(8)).toBe(0);
          });
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
          replaceWith = "Replace with this.";
        });
        it("replaces everything after an @ if the cursor is a word after that @", function(){
          input.val('not @dan grip');
          var cursorIndex = 13;
          func(input, cursorIndex, replaceWith);
          expect(input.val()).toBe('not ' + replaceWith);
        });
        it("replaces everything after an @ if the cursor is after that @", function(){
          input.val('not @dan grip');
          var cursorIndex = 7;
          func(input, cursorIndex, replaceWith);
          expect(input.val()).toBe('not ' + replaceWith);
        });
        it("replaces everything after an @ at the start of the line", function(){
          input.val('@dan grip');
          var cursorIndex = 9;
          func(input, cursorIndex, replaceWith);
          expect(input.val()).toBe(replaceWith);
        });
        it("replaces everything between @s if there are 2 @s and the cursor is between them", function(){
          input.val('@asdpo  aoisdj @asodk');
          var cursorIndex = 8;
          func(input, cursorIndex, replaceWith);
          expect(input.val()).toBe(replaceWith + ' @asodk');
        });
        it("replaces everything after the 2nd @ if there are 2 @s and the cursor after them", function(){
          input.val('@asod asdo @asd asok');
          var cursorIndex = 15;
          func(input, cursorIndex, replaceWith);
          expect(input.val()).toBe('@asod asdo ' + replaceWith);
        });
      });
    });
});
