describe("app", function() {
  afterAll(function() {
    Backbone.history.stop();
    app.initialize();
  });

  describe("initialize", function() {
    it("calls several setup functions", function() {
      spyOn(app.Router.prototype, "initialize");
      spyOn(app, "setupDummyPreloads");
      spyOn(app, "setupUser");
      spyOn(app, "setupAspects");
      spyOn(app, "setupHeader");
      spyOn(app, "setupBackboneLinks");
      spyOn(app, "setupGlobalViews");
      spyOn(app, "setupDisabledLinks");
      spyOn(app, "setupForms");
      spyOn(app, "setupAjaxErrorRedirect");

      app.initialize();

      expect(app.Router.prototype.initialize).toHaveBeenCalled();
      expect(app.setupDummyPreloads).toHaveBeenCalled();
      expect(app.setupUser).toHaveBeenCalled();
      expect(app.setupAspects).toHaveBeenCalled();
      expect(app.setupHeader).toHaveBeenCalled();
      expect(app.setupBackboneLinks).toHaveBeenCalled();
      expect(app.setupGlobalViews).toHaveBeenCalled();
      expect(app.setupDisabledLinks).toHaveBeenCalled();
      expect(app.setupForms).toHaveBeenCalled();
      expect(app.setupAjaxErrorRedirect).toHaveBeenCalled();
    });
  });

  describe("user", function() {
    it("returns false if the current_user isn't set", function() {
      app._user = undefined;
      expect(app.user()).toEqual(false);
    });

    it("sets the user if given one and returns the current user", function() {
      expect(app.user()).toBeFalsy();
      app.user({name: "alice"});
      expect(app.user().get("name")).toEqual("alice");
    });
  });

  describe("setupForms", function() {
    beforeEach(function() {
      spec.content().append("<textarea/> <input/>");
    });

    it("calls jQuery.placeholder() for inputs", function() {
      spyOn($.fn, "placeholder");
      app.setupForms();
      expect($.fn.placeholder).toHaveBeenCalled();
      expect($.fn.placeholder.calls.mostRecent().object.is($("input"))).toBe(true);
      expect($.fn.placeholder.calls.mostRecent().object.is($("textarea"))).toBe(true);
    });

    it("initializes autosize for textareas", function(){
      spyOn(window, "autosize");
      app.setupForms();
      expect(window.autosize).toHaveBeenCalled();
      expect(window.autosize.calls.mostRecent().args[0].is($("textarea"))).toBe(true);
    });
  });

  describe("setupAjaxErrorRedirect", function() {
    beforeEach(function() {
      app.setupAjaxErrorRedirect();
    });

    it("redirects to /users/sign_in on 401 ajax responses", function() {
      spyOn(app, "_changeLocation");
      $.ajax("/test");
      jasmine.Ajax.requests.mostRecent().respondWith({status: 401});
      expect(app._changeLocation).toHaveBeenCalledWith("/users/sign_in");
    });

    it("doesn't redirect on other responses", function() {
      spyOn(app, "_changeLocation");

      [200, 201, 400, 404, 500].forEach(function(code) {
        $.ajax("/test");
        jasmine.Ajax.requests.mostRecent().respondWith({status: code});
        expect(app._changeLocation).not.toHaveBeenCalled();
      });
    });

    it("doesn't redirect when error handling is suppressed", function() {
      spyOn(app, "_changeLocation");
      $.ajax("/test", {preventGlobalErrorHandling: true});
      jasmine.Ajax.requests.mostRecent().respondWith({status: 401});
      expect(app._changeLocation).not.toHaveBeenCalled();

      $.ajax("/test", {preventGlobalErrorHandling: false});
      jasmine.Ajax.requests.mostRecent().respondWith({status: 401});
      expect(app._changeLocation).toHaveBeenCalledWith("/users/sign_in");
    });

    it("doesn't redirect when global ajax events are disabled", function() {
      spyOn(app, "_changeLocation");
      $.ajaxSetup({global: false});
      $.ajax("/test");
      jasmine.Ajax.requests.mostRecent().respondWith({status: 401});
      expect(app._changeLocation).not.toHaveBeenCalled();

      $.ajaxSetup({global: true});
      $.ajax("/test");
      jasmine.Ajax.requests.mostRecent().respondWith({status: 401});
      expect(app._changeLocation).toHaveBeenCalledWith("/users/sign_in");
    });
  });

  describe("setupBackboneLinks", function() {
    beforeEach(function() {
      Backbone.history.stop();
    });

    it("calls Backbone.history.start", function() {
      spyOn(Backbone.history, "start");
      app.setupBackboneLinks();
      expect(Backbone.history.start).toHaveBeenCalledWith({pushState: true});
    });

    context("when clicking a backbone link", function() {
      beforeEach(function() {
        app.stream = {basePath: function() { return "/stream"; }};
        app.notificationsCollection = {fetch: $.noop};
        this.link = $("<a href='/backbone-link' rel='backbone'>");
        spec.content().append(this.link);
        app.setupBackboneLinks();
      });

      afterEach(function() {
        app.stream = undefined;
      });

      it("calls Backbone.history.navigate", function() {
        spyOn(Backbone.history, "navigate");
        this.link.click();
        expect(Backbone.history.navigate).toHaveBeenCalledWith("backbone-link", true);
      });

      it("fetches new notifications", function() {
        spyOn(app.notificationsCollection, "fetch");
        this.link.click();
        expect(app.notificationsCollection.fetch).toHaveBeenCalled();
      });
    });
  });
});
