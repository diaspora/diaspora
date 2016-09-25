describe("app.views.SinglePostInteractionCounts", function() {
  beforeEach(function() {
    this.post = factory.post();
    this.view = new app.views.SinglePostInteractionCounts({model: this.post});
  });

  describe("initialize", function() {
    it("calls render when the interactions change", function() {
      spyOn(app.views.SinglePostInteractionCounts.prototype, "render");
      this.view.initialize();
      expect(app.views.SinglePostInteractionCounts.prototype.render).not.toHaveBeenCalled();
      this.post.interactions.trigger("change");
      expect(app.views.SinglePostInteractionCounts.prototype.render).toHaveBeenCalled();
    });
  });
});
