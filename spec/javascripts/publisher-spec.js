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

      it("attaches updateHiddenField to the change handler on fake_message", function(){
        spec.loadFixture('aspects_index_prefill');
        spyOn(Publisher, 'updateHiddenField');
        Publisher.initialize();
        Publisher.form().find('#status_message_fake_message').change();
        expect(Publisher.updateHiddenField.mostRecentCall.args[0].type).toBe('change');
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
    describe("autocompletion", function(){
      describe("searchTermFromValue", function(){
        var func;
        beforeEach(function(){func = Publisher.autocompletion.searchTermFromValue;});
        it("returns everything after an @", function(){
          expect(func('not @dan grip')).toBe('dan grip');
        });
        it("returns nothing if there is no @", function(){
          expect(func('dan')).toBe('');
        });
        it("returns nothing for just an @", function(){
          expect(func('@')).toBe('');
        });
        it("returns everything after the last @", function(){
          expect(func('@siojfoi @dan"')).toBe('dan"');
        });
        it("returns nothing if there are letters preceding the @", function(){
          expect(func('ioj@asdo')).toBe('');
        });
      });
    });
});
