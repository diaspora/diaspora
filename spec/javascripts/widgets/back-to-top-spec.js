describe("Diaspora.Widgets.BackToTop", function() {
  var backToTop;
  beforeEach(function() {
    spec.loadFixture("aspects_index");
    backToTop = Diaspora.BaseWidget.instantiate("BackToTop", $("#back-to-top"));
    $.fx.off = true;
  });

  describe("integration", function() {
    beforeEach(function() {
      backToTop = new Diaspora.Widgets.BackToTop();

      spyOn(backToTop, "backToTop");
      spyOn(backToTop, "toggleVisibility");

      backToTop.publish("widget/ready", [$("#back-to-top")]);
    });

    it("calls backToTop when the button is clicked", function() {
      backToTop.button.click();

      expect(backToTop.backToTop).toHaveBeenCalled();
    });
  });

  describe("backToTop", function() {
    it("animates scrollTop to 0", function() {
      backToTop.backToTop($.Event());

      expect($("body").scrollTop()).toEqual(0);
    });
  });

  describe("toggleVisibility", function() {
    it("adds a visibility class to the button", function() {
      var spy = spyOn(backToTop.body, "scrollTop").and.returnValue(999);

      backToTop.toggleVisibility();

      expect(backToTop.button.hasClass("visible")).toBe(false);

      spy.and.returnValue(1001);

      backToTop.toggleVisibility();

      expect(backToTop.button.hasClass("visible")).toBe(true);
    });
  });

  afterEach(function() {
    $.fx.off = false;
  });
});
