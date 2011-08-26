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

    it("calls toggleVisibility after a delay", function() {
      jasmine.Clock.useMock();

      backToTop.window.trigger("scroll");

      expect(backToTop.toggleVisibility).not.toHaveBeenCalled();

      jasmine.Clock.tick(5000);

      expect(backToTop.toggleVisibility).toHaveBeenCalled();
    });

  });

  describe("backToTop", function() {
    it("animates scrollTop to 0", function() {
      backToTop.backToTop($.Event());

      expect($("body").scrollTop()).toEqual(0);
    });
  });

  describe("toggleVisibility", function() {
    it("animates the button's opacity based on where the user is scrolled", function() {
      var spy = spyOn(backToTop.body, "scrollTop").andReturn(999);

      backToTop.toggleVisibility();

      expect(backToTop.button.css("opacity")).toEqual("0");

      spy.andReturn(1001);

      backToTop.toggleVisibility();

      expect(backToTop.button.css("opacity")).toEqual("0.5");
    });
  });

  afterEach(function() {
    $.fx.off = false;
  });
});