describe("app.views.Hovercard", function() {
  context("user not signed in", function() {
    beforeEach(function() {
      logout();
      this.view = new app.views.Hovercard();
    });

    describe("_populateHovercardWith", function() {
      it("doesn't fetch the aspect dropdown", function() {
        spyOn(jQuery, "ajax").and.callThrough();
        this.view.parent = spec.content();
        this.view._populateHovercardWith({});
        expect(jQuery.ajax).not.toHaveBeenCalled();
      });
    });
  });

  context("user signed in", function() {
    beforeEach(function() {
      loginAs(factory.userAttrs());
      this.view = new app.views.Hovercard();
    });

    describe("initialize", function() {
      it("activates hovercards", function() {
        expect(this.view.active).toBeTruthy();
      });
    });

    describe("mouseIsOverElement", function() {
      it("returns false if the element is undefined", function() {
        expect(this.view.mouseIsOverElement(undefined, $.Event())).toBeFalsy();
      });
    });

    describe("_populateHovercard", function() {
      it("prevents global error handling for the ajax call", function() {
        spyOn(jQuery, "ajax").and.callThrough();
        this.view.parent = spec.content();
        this.view._populateHovercard();
        expect(jQuery.ajax).toHaveBeenCalledWith("undefined/hovercard.json", {preventGlobalErrorHandling: true});
      });
    });

    describe("_populateHovercardWith", function() {
      it("prevents global error handling for the ajax call", function() {
        spyOn(jQuery, "ajax").and.callThrough();
        this.view.parent = spec.content();
        this.view._populateHovercardWith({});
        expect(jQuery.ajax).toHaveBeenCalledWith(
          "undefined/aspect_membership_button",
          {preventGlobalErrorHandling: true}
        );
      });
    });
  });
});
