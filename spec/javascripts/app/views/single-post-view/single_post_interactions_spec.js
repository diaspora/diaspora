describe("app.views.SinglePostInteractions", function() {
  beforeEach(function() {
    this.post = factory.post();
    this.view = new app.views.SinglePostInteractions({model: this.post});
  });

  describe("render", function() {
    it("initializes the SinglePostInteractionCounts view", function() {
      spyOn(app.views.SinglePostInteractionCounts.prototype, "initialize");
      this.view.render();
      expect(app.views.SinglePostInteractionCounts.prototype.initialize).toHaveBeenCalled();
    });

    it("initializes the SinglePostCommentStream view", function() {
      spyOn(app.views.SinglePostCommentStream.prototype, "initialize");
      this.view.render();
      expect(app.views.SinglePostCommentStream.prototype.initialize).toHaveBeenCalled();
    });
  });

  describe("interaction changes", function() {
    it("don't drop the comment textbox value", function() {
      this.view.render();
      this.view.$("textarea").val("great post!");
      expect(this.view.$("#likes").length).toBe(0);

      this.view.model.interactions.set({"likes_count": 1});
      this.view.model.interactions.trigger("change");

      expect(this.view.$("#likes").length).toBe(1);
      expect(this.view.$("textarea").val()).toEqual("great post!");
    });
  });
});
