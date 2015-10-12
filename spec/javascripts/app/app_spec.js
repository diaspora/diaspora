describe("app", function() {
  describe("initialize", function() {
    it("calls several setup functions", function() {
      spyOn(app.Router.prototype, "initialize");
      spyOn(app, "setupDummyPreloads");
      spyOn(app, "setupUser");
      spyOn(app, "setupHeader");
      spyOn(app, "setupBackboneLinks");
      spyOn(app, "setupGlobalViews");
      spyOn(app, "setupDisabledLinks");
      spyOn(app, "setupForms");

      app.initialize();

      expect(app.Router.prototype.initialize).toHaveBeenCalled();
      expect(app.setupDummyPreloads).toHaveBeenCalled();
      expect(app.setupUser).toHaveBeenCalled();
      expect(app.setupHeader).toHaveBeenCalled();
      expect(app.setupBackboneLinks).toHaveBeenCalled();
      expect(app.setupGlobalViews).toHaveBeenCalled();
      expect(app.setupDisabledLinks).toHaveBeenCalled();
      expect(app.setupForms).toHaveBeenCalled();
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
    it("calls jQuery.placeholder() for inputs", function() {
      spyOn($.fn, "placeholder");
      app.setupForms();
      expect($.fn.placeholder).toHaveBeenCalled();
      expect($.fn.placeholder.calls.mostRecent().object.selector).toBe("input, textarea");
    });
  });
});
