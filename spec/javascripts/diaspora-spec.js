/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Diaspora", function() {
  describe("WidgetCollection", function() {
    describe("prototype", function() {
      var widgets;
      beforeEach(function() {
        widgets = new Diaspora.WidgetCollection();
      });

      describe("add", function() {
        it("adds a widget to the collection", function() {
          expect(widgets.collection["nameOfWidget"]).not.toBeDefined();
          widgets.add("nameOfWidget", function() { });
          expect(widgets.collection["nameOfWidget"]).toBeDefined();
        });

        it("sets a shortcut by referencing the object on Diaspora.widgetCollection", function() {
          expect(widgets.sup).toBeFalsy();
          widgets.add("sup", function() { });
          expect(widgets.sup).toEqual(widgets.collection.sup);
        });
      });

      describe("remove", function() {
        it("removes a widget from the collection", function() {
          widgets.add("nameOfWidget", function() { });
          expect(widgets.collection["nameOfWidget"]).toBeDefined();
          widgets.remove("nameOfWidget");
          expect(widgets.collection["nameOfWidget"]).not.toBeDefined();
        });
      });

      describe("init", function() {
        it("calls the start method on all of the widgets present", function() {
          widgets.add("nameOfWidget", function() {
            this.start = function() { }
          });

          spyOn(widgets.collection["nameOfWidget"], "start");
          widgets.init();
          expect(widgets.collection["nameOfWidget"].start).toHaveBeenCalled();
        });

        it("changes the initialized property to true", function() {
          expect(widgets.initialized).toBeFalsy();
          widgets.init();
          expect(widgets.initialized).toBeTruthy();
        });
      });
    });
  });
});
