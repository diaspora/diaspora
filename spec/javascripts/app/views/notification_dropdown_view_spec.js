describe("app.views.NotificationDropdown", function() {
  beforeEach(function() {
    spec.loadFixture("notifications");
    gon.appConfig = {settings: {podname: "MyPod"}};
    this.header = new app.views.Header();
    $("header").prepend(this.header.el);
    loginAs({guid: "foo"});
    this.header.render();
    this.collection = new app.collections.Notifications();
    this.view = new app.views.NotificationDropdown({el: "#notification-dropdown", collection: this.collection});
  });

  describe("bindCollectionEvents", function() {
    beforeEach(function() {
      this.view.collection.off("pushFront");
      this.view.collection.off("pushBack");
      this.view.collection.off("finishedLoading");
      this.view.collection.off("change:note_html");
      spyOn(this.view, "onPushFront");
      spyOn(this.view, "onPushBack");
      spyOn(this.view, "finishLoading");
      spyOn(this.view, "onNotificationChange");
    });

    it("binds collection events", function() {
      this.view.bindCollectionEvents();

      this.collection.trigger("pushFront");
      this.collection.trigger("pushBack");
      this.collection.trigger("finishedLoading");
      this.collection.trigger("change:note_html");

      expect(this.view.onPushFront).toHaveBeenCalled();
      expect(this.view.onPushBack).toHaveBeenCalled();
      expect(this.view.finishLoading).toHaveBeenCalled();
      expect(this.view.onNotificationChange).toHaveBeenCalled();
    });
  });

  describe("showDropdown", function() {
    it("Calls updateScrollbar", function() {
      spyOn(this.view, "updateScrollbar");
      this.view.showDropdown();
      expect(this.view.updateScrollbar).toHaveBeenCalled();
    });
    it("Changes CSS", function() {
      expect($("#notification-dropdown")).not.toHaveClass("dropdown-open");
      this.view.showDropdown();
      expect($("#notification-dropdown")).toHaveClass("dropdown-open");
    });
    it("Calls collection#fetch", function() {
      spyOn(this.collection, "fetch");
      this.view.showDropdown();
      expect(this.collection.fetch).toHaveBeenCalled();
    });
  });

  describe("dropdownScroll", function() {
    it("Calls collection#fetchMore if it is at the bottom", function() {
      this.view.isBottom = function() { return true; };
      spyOn(this.collection, "fetchMore");
      this.view.dropdownScroll();
      expect(this.collection.fetchMore).toHaveBeenCalled();
    });

    it("Doesn't call collection#fetchMore if it is not at the bottom", function() {
      this.view.isBottom = function() { return false; };
      spyOn(this.collection, "fetchMore");
      this.view.dropdownScroll();
      expect(this.collection.fetchMore).not.toHaveBeenCalled();
    });
  });

  describe("updateScrollbar", function() {
    it("Initializes perfectScrollbar", function() {
      this.view.perfectScrollbar = null;
      spyOn(window, "PerfectScrollbar");
      this.view.updateScrollbar();
      expect(window.PerfectScrollbar).toHaveBeenCalledWith(this.view.dropdownNotifications[0]);
      expect(this.view.perfectScrollbar).not.toBeNull();
    });

    it("Updates perfectScrollbar", function() {
      this.view.perfectScrollbar = new PerfectScrollbar(this.view.dropdownNotifications[0]);
      spyOn(this.view.perfectScrollbar, "update");
      this.view.updateScrollbar();
      expect(this.view.perfectScrollbar.update).toHaveBeenCalled();
    });
  });

  describe("destroyScrollbar", function() {
    it("destroys perfectScrollbar", function() {
      this.view.perfectScrollbar = new PerfectScrollbar(this.view.dropdownNotifications[0]);
      var spy = jasmine.createSpy();
      spyOn(this.view.perfectScrollbar, "destroy").and.callFake(spy);
      this.view.destroyScrollbar();
      expect(spy).toHaveBeenCalled();
      expect(this.view.perfectScrollbar).toBeNull();
    });

    it("doesn't destroy perfectScrollbar if it isn't initialized", function() {
      this.view.perfectScrollbar = null;
      expect(this.view.destroyScrollbar).not.toThrow();
    });
  });

  describe("notification changes", function() {
    beforeEach(function() {
      this.collection.fetch();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: spec.readFixture("notifications_collection")
      });
      this.notification = factory.notification({
        "id": 1337,
        "note_html": "<div class='stream-element' data-guid='1337'>This is a notification</div>"
      });
      expect(this.collection.length).toBeGreaterThan(0);
      expect(this.view.$(".notifications .stream-element").length).toBe(this.collection.length);
    });

    describe("onPushBack", function() {
      it("adds the notification at the end of the rendered list", function() {
        this.view.onPushBack(this.notification);
        expect(this.view.$(".notifications .stream-element").length).toBe(this.collection.length + 1);
        expect(this.view.$(".notifications .stream-element").last().text()).toBe("This is a notification");
      });

      it("calls afterNotificationChanges", function() {
        spyOn(this.view, "afterNotificationChanges");
        this.view.onPushBack(this.notification);
        expect(this.view.afterNotificationChanges).toHaveBeenCalled();
        var node = this.view.afterNotificationChanges.calls.mostRecent().args[0];
        expect(node.text()).toBe("This is a notification");
      });
    });

    describe("onPushFront", function() {
      it("adds the notification to the beginning of the rendered list", function() {
        this.view.onPushFront(this.notification);
        expect(this.view.$(".notifications .stream-element").length).toBe(this.collection.length + 1);
        expect(this.view.$(".notifications .stream-element").first().text()).toBe("This is a notification");
      });

      it("calls afterNotificationChanges", function() {
        spyOn(this.view, "afterNotificationChanges");
        this.view.onPushFront(this.notification);
        expect(this.view.afterNotificationChanges).toHaveBeenCalled();
        var node = this.view.afterNotificationChanges.calls.mostRecent().args[0];
        expect(node.text()).toBe("This is a notification");
      });
    });

    describe("onNotificationChange", function() {
      beforeEach(function() {
        // create a notification which replaces the first in the collection
        var firstNoteId = this.collection.models[0].attributes.id;
        this.notification = factory.notification({
          "id": firstNoteId,
          "note_html": "<div class='stream-element' data-guid='" + firstNoteId + "'>This is a notification</div>"
        });
      });

      it("replaces the notification in the rendered list", function() {
        this.view.onNotificationChange(this.notification);
        expect(this.view.$(".notifications .stream-element").length).toBe(this.collection.length);
        expect(this.view.$(".notifications .stream-element").first().text()).toBe("This is a notification");
      });

      it("calls afterNotificationChanges", function() {
        spyOn(this.view, "afterNotificationChanges");
        this.view.onNotificationChange(this.notification);
        expect(this.view.afterNotificationChanges).toHaveBeenCalled();
        var node = this.view.afterNotificationChanges.calls.mostRecent().args[0];
        expect(node.text()).toBe("This is a notification");
      });
    });
  });
});
