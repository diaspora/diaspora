/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

describe("Diaspora", function() {
  describe("widgets", function() {
    describe("publisher", function() {
      describe("start", function() {
        it("calls updateHiddenField", function() {
          spec.loadFixture('aspects_index_prefill');
          spyOn(Diaspora.widgets.publisher, 'updateHiddenField');
         Diaspora.widgets.publisher.start();
          expect(Diaspora.widgets.publisher.updateHiddenField).toHaveBeenCalled();
        });

        it("attaches updateHiddenField to the change handler on fake_message", function() {
          spec.loadFixture('aspects_index_prefill');
          spyOn(Diaspora.widgets.publisher, 'updateHiddenField');
          Diaspora.widgets.publisher.start();
          Diaspora.widgets.publisher.$fakeMessage.change();
          expect(Diaspora.widgets.publisher.updateHiddenField.mostRecentCall.args[0].type).toBe('change');
        });

        it("calls toggle when it does not have text", function() {
          spec.loadFixture('aspects_index');
          spyOn(Diaspora.widgets.publisher, 'toggle');
          Diaspora.widgets.publisher.start();
          expect(Diaspora.widgets.publisher.toggle).toHaveBeenCalled();
        });

        it("does not call toggle when there is prefilled text", function() {
          spec.loadFixture('aspects_index_prefill');
          spyOn(Diaspora.widgets.publisher, 'toggle');
          Diaspora.widgets.publisher.start();
          expect(Diaspora.widgets.publisher.toggle).not.toHaveBeenCalled();
        });
      });
      describe("toggle", function() {
        beforeEach(function() {
          spec.loadFixture('aspects_index');
          Diaspora.widgets.publisher.start();
        });
        it("toggles the closed class", function() {
          expect(Diaspora.widgets.publisher.$publisher.hasClass('closed')).toBeTruthy();
          Diaspora.widgets.publisher.toggle();
          expect(Diaspora.widgets.publisher.$publisher.hasClass('closed')).toBeFalsy();

          expect(Diaspora.widgets.publisher.$publisher.hasClass('closed')).toBeFalsy();
          Diaspora.widgets.publisher.toggle();
          expect(Diaspora.widgets.publisher.$publisher.hasClass('closed')).toBeTruthy;
        });

        it("toggles the options_and_submit div", function() {
          expect(Diaspora.widgets.publisher.$publisher.find(".options_and_submit").is(":visible")).toBeFalsy();
          Diaspora.widgets.publisher.toggle();
          expect(Diaspora.widgets.publisher.$publisher.find(".options_and_submit").is(":visible")).toBeTruthy();


          expect(Diaspora.widgets.publisher.$publisher.find(".options_and_submit").is(":visible")).toBeTruthy();
          Diaspora.widgets.publisher.toggle();
          expect(Diaspora.widgets.publisher.$publisher.find(".options_and_submit").is(":visible")).toBeFalsy();
        });
      });

      describe("updateHiddenField", function() {
        beforeEach(function() {
          spec.loadFixture('aspects_index_prefill');
        });

        it("copies the value of fake_message to message", function() {
          Diaspora.widgets.publisher.updateHiddenField();
          expect(Diaspora.widgets.publisher.$realMessage.val()).toBe(
              Diaspora.widgets.publisher.$fakeMessage.val());
        });
      });
    });
  });
});