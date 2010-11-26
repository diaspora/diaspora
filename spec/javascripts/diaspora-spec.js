describe("Diaspora", function() {
  describe("widgets", function() {
    beforeEach(function() {
      Diaspora.widgets.pageWidgets = {};
    });
    describe("add", function() {
      it("adds a widget to the list of pageWidgets", function() {
        expect(Diaspora.widgets.pageWidgets["nameOfWidget"]).not.toBeDefined();
        Diaspora.widgets.add("nameOfWidget", {});
        expect(Diaspora.widgets.pageWidgets["nameOfWidget"]).toBeDefined();
      });
    });
    describe("remove", function() {
      it("removes a widget from the list of pageWidgets", function() {
        Diaspora.widgets.add("nameOfWidget", {});
        expect(Diaspora.widgets.pageWidgets["nameOfWidget"]).toBeDefined();
        Diaspora.widgets.remove("nameOfWidget");
        expect(Diaspora.widgets.pageWidgets["nameOfWidget"]).not.toBeDefined();
      });
    });
    describe("init", function() {
      Diaspora.widgets.add("nameOfWidget", {start:$.noop});
      spyOn(Diaspora.widgets.pageWidgets["nameOfWidget"], "start");
      Diaspora.widgets.init();
      expect(Diaspora.widgets.pageWidgets["nameOfWidget"].start).toHaveBeenCalled();
    });
  });
});
