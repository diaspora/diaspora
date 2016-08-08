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
      spyOn(this.view, "onPushFront");
      spyOn(this.view, "onPushBack");
      spyOn(this.view, "finishLoading");
    });

    it("binds collection events", function() {
      this.view.bindCollectionEvents();

      this.collection.trigger("pushFront");
      this.collection.trigger("pushBack");
      this.collection.trigger("finishedLoading");

      expect(this.view.onPushFront).toHaveBeenCalled();
      expect(this.view.onPushBack).toHaveBeenCalled();
      expect(this.view.finishLoading).toHaveBeenCalled();
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
      this.view.perfectScrollbarInitialized = false;
      spyOn($.fn, "perfectScrollbar");
      this.view.updateScrollbar();
      expect($.fn.perfectScrollbar).toHaveBeenCalledWith();
      expect($.fn.perfectScrollbar.calls.mostRecent().object).toEqual(this.view.dropdownNotifications);
      expect(this.view.perfectScrollbarInitialized).toBeTruthy();
    });

    it("Updates perfectScrollbar", function() {
      this.view.perfectScrollbarInitialized = true;
      this.view.dropdownNotifications.perfectScrollbar();
      spyOn($.fn, "perfectScrollbar");
      this.view.updateScrollbar();
      expect($.fn.perfectScrollbar).toHaveBeenCalledWith("update");
      expect($.fn.perfectScrollbar.calls.mostRecent().object).toEqual(this.view.dropdownNotifications);
      expect(this.view.perfectScrollbarInitialized).toBeTruthy();
    });
  });

  describe("destroyScrollbar", function() {
    it("destroys perfectScrollbar", function() {
      this.view.perfectScrollbarInitialized = true;
      this.view.dropdownNotifications.perfectScrollbar();
      spyOn($.fn, "perfectScrollbar");
      this.view.destroyScrollbar();
      expect($.fn.perfectScrollbar).toHaveBeenCalledWith("destroy");
      expect($.fn.perfectScrollbar.calls.mostRecent().object).toEqual(this.view.dropdownNotifications);
      expect(this.view.perfectScrollbarInitialized).toBeFalsy();
    });

    it("doesn't destroy perfectScrollbar if it isn't initialized", function() {
      this.view.perfectScrollbarInitialized = false;
      spyOn($.fn, "perfectScrollbar");
      this.view.destroyScrollbar();
      expect($.fn.perfectScrollbar).not.toHaveBeenCalled();
    });
  });
});
