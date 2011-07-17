/*   Copyright (c) 2010, Diaspora Inc.  This file is
*   licensed under the Affero General Public License version 3 or later.  See
*   the COPYRIGHT file.
*/

describe("Diaspora", function() {
  describe("widgets", function() { 
    describe("add", function() {
      it("adds a widget to the collection", function() {
        expect(Diaspora.widgets.collection["nameOfWidget"]).not.toBeDefined();
        Diaspora.widgets.add("nameOfWidget", function() { });
        expect(Diaspora.widgets.collection["nameOfWidget"]).toBeDefined();
      });

      it("sets a shortcut by referencing the object on Diaspora.widgetCollection", function() {
        expect(Diaspora.widgets.sup).toBeFalsy();
        Diaspora.widgets.add("sup", function() { });
        expect(Diaspora.widgets.sup).toEqual(Diaspora.widgets.collection.sup);
      });
    });

    describe("remove", function() {
      it("removes a widget from the collection", function() {
        Diaspora.widgets.add("nameOfWidget", function() { });
        expect(Diaspora.widgets.collection["nameOfWidget"]).toBeDefined();
        Diaspora.widgets.remove("nameOfWidget");
        expect(Diaspora.widgets.collection["nameOfWidget"]).not.toBeDefined();
      });
    });

    describe("init", function() {
      it("publishes the widget/ready event on all of the present widgets", function() {
        Diaspora.widgets.add("nameOfWidget", function() {
	  var self = this;
          this.subscribe("widget/ready", function() {
	    self.called = true;
	  });
        });

        Diaspora.widgets.initialize();
        expect(Diaspora.widgets.collection.nameOfWidget.called).toBeTruthy();
      });

      it("changes the initialized property to true", function() {
	Diaspora.widgets.initialized = false;
        Diaspora.widgets.initialize();
        expect(Diaspora.widgets.initialized).toBeTruthy();
      });
    });
  });
  describe("EventBroker", function() {
    describe("extend", function() {
      var obj;
      beforeEach(function() {
	obj = {};
      });

      it("adds an events container to an object", function() {
	      expect(typeof Diaspora.EventBroker.extend(obj).eventsContainer).toEqual("object");
      });

      it("adds a publish method to an object", function() {
	      expect(typeof Diaspora.EventBroker.extend(obj).publish).toEqual("function");
      });

      it("adds a subscribe method to an object", function() {
	      expect(typeof Diaspora.EventBroker.extend(obj).subscribe).toEqual("function");
      });
    }); 

    describe("subscribe", function() {
      it("subscribes to an event specified by an id", function() {
        Diaspora.widgets.eventsContainer.data("events", undefined);
        Diaspora.widgets.subscribe("testing/event", function() { });
        expect(Diaspora.widgets.eventsContainer.data("events")["testing/event"]).toBeDefined();
      });

      it("accepts a context in which the function will always be called", function() {
        var foo = "bar";

        Diaspora.widgets.subscribe("testing/context", function() { foo = this.foo; });
        Diaspora.widgets.publish("testing/context");
        expect(foo).toEqual(undefined);

        Diaspora.widgets.subscribe("testing/context_", function() { foo = this.foo;  }, { foo: "hello" });
        Diaspora.widgets.publish("testing/context_");
        expect(foo).toEqual("hello");
      });
    });

    describe("publish", function() {
      it("triggers events that are related to the specified id", function() {
        var called = false;

        Diaspora.widgets.subscribe("testing/event", function() {
          called = true;
        });

        Diaspora.widgets.publish("testing/event");

        expect(called).toBeTruthy();
      });
    });
  });
});
