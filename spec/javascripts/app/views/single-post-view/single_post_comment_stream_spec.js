describe("app.views.SinglePostCommentStream", function() {
  beforeEach(function() {
    this.post = factory.postWithInteractions();
    this.view = new app.views.SinglePostCommentStream({model: this.post});
  });

  describe("initialize", function() {
    it("sets this.CommentView to app.views.ExpandedComment", function() {
      expect(this.view.CommentView).toBe(app.views.ExpandedComment);
    });

    it("calls highlightPermalinkComment on hashchange", function() {
      spyOn(app.views.SinglePostCommentStream.prototype, "highlightPermalinkComment");
      this.view.initialize();
      $(window).trigger("hashchange");
      expect(app.views.SinglePostCommentStream.prototype.highlightPermalinkComment).toHaveBeenCalled();
    });

    it("calls setupBindings", function() {
      spyOn(app.views.SinglePostCommentStream.prototype, "setupBindings");
      this.view.initialize();
      expect(app.views.SinglePostCommentStream.prototype.setupBindings).toHaveBeenCalled();
    });
  });

  describe("highlightPermalinkComment", function() {
    beforeEach(function() {
      this.view.render();
    });

    it("calls highlightComment if the comment is visible", function() {
      document.location.hash = "#" + this.post.comments.first().get("guid");
      spyOn(this.view, "highlightComment");
      this.view.highlightPermalinkComment();
      expect(this.view.highlightComment).toHaveBeenCalledWith(document.location.hash);
    });

    it("doesn't call expandComments if the comment is visible", function() {
      document.location.hash = "#" + this.post.comments.first().get("guid");
      spyOn(this.view, "expandComments");
      this.view.highlightPermalinkComment();
      expect(this.view.expandComments).not.toHaveBeenCalled();
    });

    it("calls expandComments if the comment isn't visible yet", function() {
      document.location.hash = "#404-guid-not-found";
      spyOn(this.view, "expandComments");
      this.view.highlightPermalinkComment();
      expect(this.view.expandComments).toHaveBeenCalled();
    });

    it("calls hightlightComment after the comments are expanded", function() {
      document.location.hash = "#404-guid-not-found";
      spyOn(_, "defer").and.callFake(function(fn, arg) { fn(arg); });
      spyOn(this.view, "highlightComment");
      this.view.highlightPermalinkComment();
      this.view.trigger("commentsExpanded");
      expect(this.view.highlightComment).toHaveBeenCalledWith(document.location.hash);
    });
  });

  describe("highlightComment", function() {
    beforeEach(function() {
      this.view.render();
    });

    it("removes the existing highlighting and highlights the given comment", function() {
      var firstGuidSelector = "#" + this.post.comments.first().get("guid"),
          lastGuidSelector = "#" + this.post.comments.last().get("guid");
      this.view.$(lastGuidSelector).addClass("highlighted");
      this.view.highlightComment(firstGuidSelector);
      expect(this.view.$(lastGuidSelector)).not.toHaveClass("highlighted");
      expect(this.view.$(firstGuidSelector)).toHaveClass("highlighted");
    });
  });

  describe("postRenderTemplate", function() {
    it("calls app.views.CommentStream.prototype.postRenderTemplate", function() {
      spyOn(app.views.CommentStream.prototype, "postRenderTemplate");
      this.view.postRenderTemplate();
      expect(app.views.CommentStream.prototype.postRenderTemplate).toHaveBeenCalled();
    });

    it("shows the new comment form wrapper", function() {
      this.view.render();
      this.view.$(".new-comment-form-wrapper").addClass("hidden");
      expect(this.view.$(".new-comment-form-wrapper")).toHaveClass("hidden");
      this.view.postRenderTemplate();
      expect(this.view.$(".new-comment-form-wrapper")).not.toHaveClass("hidden");
    });

    it("defers a highlightPermalinkComment call", function() {
      spyOn(_, "defer").and.callFake(function(fn) { fn(); });
      spyOn(this.view, "highlightPermalinkComment");
      this.view.postRenderTemplate();
      expect(this.view.highlightPermalinkComment).toHaveBeenCalled();
    });
  });
});
