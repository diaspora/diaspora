describe("app.views.Hovercard", function() {
  beforeEach(function() {
    this.view = new app.views.Hovercard();
  });

  describe("mouseIsOverElement", function() {
    it("returns false if the element is undefined", function() {
      expect(this.view.mouseIsOverElement(undefined, $.Event())).toBeFalsy();
    });
  });
});
