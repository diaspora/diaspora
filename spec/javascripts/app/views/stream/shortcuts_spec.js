describe("app.views.StreamShortcuts", function () {

  beforeEach(function() {
    this.post1 = factory.post({author : factory.author({name : "Rebecca Black", id : 1492})});
    this.post2 = factory.post({author : factory.author({name : "John Stamos", id : 1987})});

    this.stream = new app.models.Stream();
    this.stream.add([this.post1, this.post2]);
    this.streamView = new app.views.Stream({model : this.stream});
    spec.content().html(this.streamView.render().el);
    this.view = new app.views.StreamShortcuts({el: $(document)});

    expect(spec.content().find("div.stream-element.loaded").length).toBe(2);
  });

  describe("initialize", function() {
    it("setups the shortcuts", function() {
      spyOn(app.helpers, "Shortcuts").and.callThrough();
      spyOn(app.views.StreamShortcuts.prototype, "_onHotkeyDown");
      spyOn(app.views.StreamShortcuts.prototype, "_onHotkeyUp");
      this.view = new app.views.StreamShortcuts({el: $(document)});
      expect(app.helpers.Shortcuts.calls.count()).toBe(2);

      $("body").trigger($.Event("keydown", {which: Keycodes.J, target: {type: "textarea"}}));
      $("body").trigger($.Event("keyup", {which: Keycodes.J, target: {type: "textarea"}}));
      expect(app.views.StreamShortcuts.prototype._onHotkeyDown).not.toHaveBeenCalled();
      expect(app.views.StreamShortcuts.prototype._onHotkeyUp).not.toHaveBeenCalled();

      var e = $.Event("keydown", {which: Keycodes.J, target: {type: "div"}});
      $("body").trigger(e);
      expect(app.views.StreamShortcuts.prototype._onHotkeyDown).toHaveBeenCalledWith(e);

      e = $.Event("keyup", {which: Keycodes.J, target: {type: "div"}});
      $("body").trigger(e);
      expect(app.views.StreamShortcuts.prototype._onHotkeyUp).toHaveBeenCalledWith(e);
    });
  });

  describe("_onHotkeyDown", function() {
    it("calls goToNext when the user pressed 'J'", function() {
      spyOn(this.view, "gotoNext");
      var e = $.Event("keydown", {which: Keycodes.J, target: {type: "div"}});
      this.view._onHotkeyDown(e);
      expect(this.view.gotoNext).toHaveBeenCalled();
    });

    it("calls gotoPrev when the user pressed 'K'", function() {
      spyOn(this.view, "gotoPrev");
      var e = $.Event("keydown", {which: Keycodes.K, target: {type: "div"}});
      this.view._onHotkeyDown(e);
      expect(this.view.gotoPrev).toHaveBeenCalled();
    });
  });

  describe("_onHotkeyUp", function() {
    it("calls commentSelected when the user pressed 'C'", function() {
      spyOn(this.view, "commentSelected");
      var e = $.Event("keyup", {which: Keycodes.C, target: {type: "div"}});
      this.view._onHotkeyUp(e);
      expect(this.view.commentSelected).toHaveBeenCalled();
    });

    it("calls likeSelected when the user pressed 'L'", function() {
      spyOn(this.view, "likeSelected");
      var e = $.Event("keyup", {which: Keycodes.L, target: {type: "div"}});
      this.view._onHotkeyUp(e);
      expect(this.view.likeSelected).toHaveBeenCalled();
    });

    it("calls expandSelected when the user pressed 'M'", function() {
      spyOn(this.view, "expandSelected");
      var e = $.Event("keyup", {which: Keycodes.M, target: {type: "div"}});
      this.view._onHotkeyUp(e);
      expect(this.view.expandSelected).toHaveBeenCalled();
    });

    it("calls openFirstLinkSelected when the user pressed 'O'", function() {
      spyOn(this.view, "openFirstLinkSelected");
      var e = $.Event("keyup", {which: Keycodes.O, target: {type: "div"}});
      this.view._onHotkeyUp(e);
      expect(this.view.openFirstLinkSelected).toHaveBeenCalled();
    });

    it("calls reshareSelected when the user pressed 'R'", function() {
      spyOn(this.view, "reshareSelected");
      var e = $.Event("keyup", {which: Keycodes.R, target: {type: "div"}});
      this.view._onHotkeyUp(e);
      expect(this.view.reshareSelected).toHaveBeenCalled();
    });
  });

  describe("gotoNext", function() {
    it("calls selectPost", function() {
      spyOn(this.view, "selectPost");
      this.view.gotoNext();
      expect(this.view.selectPost).toHaveBeenCalled();
    });
  });

  describe("gotoPrev", function() {
    it("calls selectPost", function() {
      spyOn(this.view, "selectPost");
      this.view.gotoPrev();
      expect(this.view.selectPost).toHaveBeenCalled();
    });
  });
});
