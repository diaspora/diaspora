describe("app.views.SinglePostCommentStream", function() {
  beforeEach(function() {
    this.post = factory.post();
    this.view = new app.views.SinglePostCommentStream({model: this.post});
  });

  describe("initialize", function() {
    it("sets this.CommentView to app.views.ExpandedComment", function() {
      expect(this.view.CommentView).toBe(app.views.ExpandedComment);
    });

    it("calls render when the comments collection has been resetted", function() {
      spyOn(app.views.SinglePostCommentStream.prototype, "render");
      this.view.initialize();
      expect(app.views.SinglePostCommentStream.prototype.render).not.toHaveBeenCalled();
      this.post.comments.reset();
      expect(app.views.SinglePostCommentStream.prototype.render).toHaveBeenCalled();
    });

    it("calls setupBindings", function() {
      spyOn(app.views.SinglePostCommentStream.prototype, "setupBindings");
      this.view.initialize();
      expect(app.views.SinglePostCommentStream.prototype.setupBindings).toHaveBeenCalled();
    });
  });
});
