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

      describe("subscribe", function() {
        it("subscribes to an event specified by an id", function() {
          expect(widgets.eventsContainer.data("events")).not.toBeDefined();
          widgets.subscribe("testing/event", function() { });
          expect(widgets.eventsContainer.data("events")["testing/event"]).toBeDefined();
        });

        it("accepts a context in which the function will always be called", function() {
           var foo = "bar";
           widgets.subscribe("testing/context", function() { foo = this.foo; });
           widgets.publish("testing/context");
           expect(foo).toEqual(undefined);

           widgets.subscribe("testing/context_", function() { foo = this.foo;  }, { foo: "hello" });
           widgets.publish("testing/context_");
           expect(foo).toEqual("hello");
        });
      });

      describe("publish", function() {
        it("triggers events that are related to the specified id", function() {
          var called = false;

          widgets.subscribe("testing/event", function() {
            called = true;
          });

          widgets.publish("testing/event");

          expect(called).toBeTruthy();
        });
      });
    });
  });
});
