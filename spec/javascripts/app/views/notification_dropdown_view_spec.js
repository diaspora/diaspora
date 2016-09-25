describe("app.views.NotificationDropdown", function() {
  beforeEach(function (){
    spec.loadFixture("notifications");
    gon.appConfig = {settings: {podname: "MyPod"}};
    this.header = new app.views.Header();
    $("header").prepend(this.header.el);
    loginAs({guid: "foo"});
    this.header.render();
    this.view = new app.views.NotificationDropdown({el: "#notification-dropdown"});
  });

  context("showDropdown", function(){
    it("Calls resetParam()", function(){
      spyOn(this.view, "resetParams");
      this.view.showDropdown();
      expect(this.view.resetParams).toHaveBeenCalled();
    });
    it("Calls updateScrollbar()", function(){
      spyOn(this.view, "updateScrollbar");
      this.view.showDropdown();
      expect(this.view.updateScrollbar).toHaveBeenCalled();
    });
    it("Changes CSS", function(){
      expect($("#notification-dropdown")).not.toHaveClass("dropdown-open");
      this.view.showDropdown();
      expect($("#notification-dropdown")).toHaveClass("dropdown-open");
    });
    it("Calls getNotifications()", function(){
      spyOn(this.view, "getNotifications");
      this.view.showDropdown();
      expect(this.view.getNotifications).toHaveBeenCalled();
    });
  });

  context("dropdownScroll", function(){
    it("Calls getNotifications if is at the bottom and has more notifications to load", function(){
      this.view.isBottom = function(){ return true; };
      this.view.hasMoreNotifs = true;
      spyOn(this.view, "getNotifications");
      this.view.dropdownScroll();
      expect(this.view.getNotifications).toHaveBeenCalled();
    });

    it("Doesn't call getNotifications if is not at the bottom", function(){
      this.view.isBottom = function(){ return false; };
      this.view.hasMoreNotifs = true;
      spyOn(this.view, "getNotifications");
      this.view.dropdownScroll();
      expect(this.view.getNotifications).not.toHaveBeenCalled();
    });

    it("Doesn't call getNotifications if is not at the bottom", function(){
      this.view.isBottom = function(){ return true; };
      this.view.hasMoreNotifs = false;
      spyOn(this.view, "getNotifications");
      this.view.dropdownScroll();
      expect(this.view.getNotifications).not.toHaveBeenCalled();
    });
  });

  context("getNotifications", function(){
    it("Has more notifications", function(){
      var response = ["", "", "", "", ""];
      spyOn($, "getJSON").and.callFake(function(url, callback){ callback(response); });
      this.view.getNotifications();
      expect(this.view.hasMoreNotifs).toBe(true);
    });
    it("Has no more notifications", function(){
      spyOn($, "getJSON").and.callFake(function(url, callback){ callback([]); });
      this.view.getNotifications();
      expect(this.view.hasMoreNotifs).toBe(false);
    });
    it("Correctly sets the next page", function(){
      spyOn($, "getJSON").and.callFake(function(url, callback){ callback([]); });
      expect(typeof this.view.nextPage).toBe("undefined");
      this.view.getNotifications();
      expect(this.view.nextPage).toBe(3);
    });
    it("Increase the page count", function(){
      var response = ["", "", "", "", ""];
      spyOn($, "getJSON").and.callFake(function(url, callback){ callback(response); });
      this.view.getNotifications();
      expect(this.view.nextPage).toBe(3);
      this.view.getNotifications();
      expect(this.view.nextPage).toBe(4);
    });
    it("Calls renderNotifications()", function(){
      spyOn($, "getJSON").and.callFake(function(url, callback){ callback([]); });
      spyOn(this.view, "renderNotifications");
      this.view.getNotifications();
      expect(this.view.renderNotifications).toHaveBeenCalled();
    });
    it("Adds the notifications to this.notifications", function(){
      var response = ["", "", "", "", ""];
      this.view.notifications.length = 0;
      spyOn($, "getJSON").and.callFake(function(url, callback){ callback(response); });
      this.view.getNotifications();
      expect(this.view.notifications).toEqual(response);
    });
  });

  context("renderNotifications", function(){
    it("Removes the previous notifications", function(){
      this.view.dropdownNotifications.append("<div class=\"media stream-element\">Notification</div>");
      expect(this.view.dropdownNotifications.find(".media.stream-element").length).toBe(1);
      this.view.renderNotifications();
      expect(this.view.dropdownNotifications.find(".media.stream-element").length).toBe(0);
    });
    it("Calls hideAjaxLoader()", function(){
      spyOn(this.view, "hideAjaxLoader");
      this.view.renderNotifications();
      expect(this.view.hideAjaxLoader).toHaveBeenCalled();
    });
    it("Calls updateScrollbar()", function(){
      spyOn(this.view, "updateScrollbar");
      this.view.renderNotifications();
      expect(this.view.updateScrollbar).toHaveBeenCalled();
    });
  });

  context("updateScrollbar", function() {
    it("Initializes perfectScrollbar", function(){
      this.view.perfectScrollbarInitialized = false;
      spyOn($.fn, "perfectScrollbar");
      this.view.updateScrollbar();
      expect($.fn.perfectScrollbar).toHaveBeenCalledWith();
      expect($.fn.perfectScrollbar.calls.mostRecent().object).toEqual(this.view.dropdownNotifications);
      expect(this.view.perfectScrollbarInitialized).toBeTruthy();
    });

    it("Updates perfectScrollbar", function(){
      this.view.perfectScrollbarInitialized = true;
      this.view.dropdownNotifications.perfectScrollbar();
      spyOn($.fn, "perfectScrollbar");
      this.view.updateScrollbar();
      expect($.fn.perfectScrollbar).toHaveBeenCalledWith("update");
      expect($.fn.perfectScrollbar.calls.mostRecent().object).toEqual(this.view.dropdownNotifications);
      expect(this.view.perfectScrollbarInitialized).toBeTruthy();
    });
  });

  context("destroyScrollbar", function() {
    it("destroys perfectScrollbar", function(){
      this.view.perfectScrollbarInitialized = true;
      this.view.dropdownNotifications.perfectScrollbar();
      spyOn($.fn, "perfectScrollbar");
      this.view.destroyScrollbar();
      expect($.fn.perfectScrollbar).toHaveBeenCalledWith("destroy");
      expect($.fn.perfectScrollbar.calls.mostRecent().object).toEqual(this.view.dropdownNotifications);
      expect(this.view.perfectScrollbarInitialized).toBeFalsy();
    });

    it("doesn't destroy perfectScrollbar if it isn't initialized", function(){
      this.view.perfectScrollbarInitialized = false;
      spyOn($.fn, "perfectScrollbar");
      this.view.destroyScrollbar();
      expect($.fn.perfectScrollbar).not.toHaveBeenCalled();
    });
  });
});
