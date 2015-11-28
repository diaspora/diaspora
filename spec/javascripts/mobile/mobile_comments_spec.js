describe("Diaspora.Mobile.Comments", function(){
  describe("toggleComments", function() {
    beforeEach(function() {
      spec.loadFixture("aspects_index_mobile_post_with_comments");
      this.link = $(".stream .show_comments").first();
      spyOn(Diaspora.Mobile.Comments, "showComments");
      spyOn(Diaspora.Mobile.Comments, "hideComments");
    });

    it("calls showComments", function() {
      Diaspora.Mobile.Comments.toggleComments(this.link);
      expect(Diaspora.Mobile.Comments.showComments).toHaveBeenCalled();
      expect(Diaspora.Mobile.Comments.hideComments).not.toHaveBeenCalled();
    });

    it("calls hideComments if the link class is 'active'", function() {
      this.link.addClass("active");
      Diaspora.Mobile.Comments.toggleComments(this.link);
      expect(Diaspora.Mobile.Comments.showComments).not.toHaveBeenCalled();
      expect(Diaspora.Mobile.Comments.hideComments).toHaveBeenCalled();
    });

    it("doesn't call any function if the link class is 'loading'", function() {
      this.link.addClass("loading");
      Diaspora.Mobile.Comments.toggleComments(this.link);
      expect(Diaspora.Mobile.Comments.showComments).not.toHaveBeenCalled();
      expect(Diaspora.Mobile.Comments.hideComments).not.toHaveBeenCalled();
    });
  });

  describe("showUnloadedComments", function() {
    beforeEach(function() {
      spec.loadFixture("aspects_index_mobile_post_with_comments");
      this.link = $(".stream .show_comments").first();
      this.bottomBar = this.link.closest(".bottom_bar").first();
      this.commentActionLink = this.bottomBar.find("a.comment-action");
    });

    it("adds the 'loading' class to the link", function() {
      Diaspora.Mobile.Comments.showUnloadedComments(this.link, this.bottomBar, this.commentActionLink);
      expect($(".show_comments").first()).toHaveClass("loading");
    });

    it("removes the 'loading' class if the request failed", function() {
      Diaspora.Mobile.Comments.showUnloadedComments(this.link, this.bottomBar, this.commentActionLink);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect($(".show_comments").first()).not.toHaveClass("loading");
    });

    it("adds the 'active' class if the request succeeded", function() {
      Diaspora.Mobile.Comments.showUnloadedComments(this.link, this.bottomBar, this.commentActionLink);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, contentType: "text/plain", responseText: "test"});
      expect($(".show_comments").first()).toHaveClass("active");
      expect($(".show_comments").first()).not.toHaveClass("loading");
    });

    it("calls showCommentBox", function() {
      spyOn(Diaspora.Mobile.Comments, "showCommentBox");
      Diaspora.Mobile.Comments.showUnloadedComments(this.link, this.bottomBar, this.commentActionLink);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, contentType: "text/plain", responseText: "test"});
      expect(Diaspora.Mobile.Comments.showCommentBox).toHaveBeenCalledWith(this.commentActionLink);
    });

    it("adds the response text to the comments list", function() {
      Diaspora.Mobile.Comments.showUnloadedComments(this.link, this.bottomBar, this.commentActionLink);
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        contentType: "text/plain",
        responseText: "<div class=\"commentContainerForTest\">new comments</div>"
      });
      expect($(".stream .stream_element").first()).toContainElement(".commentContainerForTest");
    });
  });

  describe("showCommentBox", function() {
    beforeEach(function() {
      spec.loadFixture("aspects_index_mobile_post_with_comments");
      this.link = $(".stream .comment-action").first();
    });

    it("adds the 'loading' class to the link", function() {
      Diaspora.Mobile.Comments.showCommentBox(this.link);
      expect($(".comment-action").first()).toHaveClass("loading");
    });

    it("removes the 'loading' class if the request failed", function() {
      Diaspora.Mobile.Comments.showCommentBox(this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect($(".comment-action").first()).not.toHaveClass("loading");
    });

    it("fires an AJAX call", function() {
      spyOn(jQuery, "ajax");
      Diaspora.Mobile.Comments.showCommentBox(this.link);
      expect(jQuery.ajax).toHaveBeenCalled();
    });

    it("calls appendCommentBox", function() {
      spyOn(Diaspora.Mobile.Comments, "appendCommentBox");
      Diaspora.Mobile.Comments.showCommentBox(this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, contentType: "text/plain", responseText: "test"});
      expect(Diaspora.Mobile.Comments.appendCommentBox).toHaveBeenCalledWith(this.link, "test");
    });

    it("doesn't do anything if the link class is 'loading'", function() {
      spyOn(jQuery, "ajax");
      this.link.addClass("loading");
      Diaspora.Mobile.Comments.showCommentBox(this.link);
      expect(jQuery.ajax).not.toHaveBeenCalled();
    });

    it("doesn't do anything if the link class is not 'inactive'", function() {
      spyOn(jQuery, "ajax");
      this.link.removeClass("inactive");
      Diaspora.Mobile.Comments.showCommentBox(this.link);
      expect(jQuery.ajax).not.toHaveBeenCalled();
    });
  });

  describe("createComment", function () {
    beforeEach(function() {
      spec.loadFixture("aspects_index_mobile_post_with_comments");
      var commentBoxHtml = spec.fixtureHtml("comments_mobile_commentbox");
      var link = $(".stream .comment-action").first();
      Diaspora.Mobile.Comments.showCommentBox(link);
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        contentType: "text/html",
        responseText: commentBoxHtml
      });
      $(".stream .new_comment").submit(Diaspora.Mobile.Comments.submitComment);
    });

    it("doesn't submit an empty comment", function() {
      var form = $(".stream .new_comment").first();
      spyOn(jQuery, "ajax");
      form.submit();
      expect(jQuery.ajax).not.toHaveBeenCalled();
    });
  });
});
