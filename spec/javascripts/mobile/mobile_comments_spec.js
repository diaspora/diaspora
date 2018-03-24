describe("Diaspora.Mobile.Comments", function(){
  beforeEach(function() {
    spec.loadFixture("aspects_index_mobile_post_with_comments");
    this.bottomBar = $(".bottom-bar").first();
    this.link = $(".stream .show-comments").first();
  });

  describe("initialize", function() {
    it("calls submitComment when the comment form has been submitted", function() {
      spyOn(Diaspora.Mobile.Comments, "submitComment").and.returnValue(false);
      Diaspora.Mobile.Comments.initialize();
      Diaspora.Mobile.Comments.showCommentBox($(".stream .comment-action").first());
      $(".stream .new-comment").first().submit();
      expect(Diaspora.Mobile.Comments.submitComment).toHaveBeenCalled();
    });
  });

  describe("toggleComments", function() {
    beforeEach(function() {
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
      this.commentActionLink = this.bottomBar.find("a.comment-action");
    });

    it("adds the 'loading' class to the link", function() {
      Diaspora.Mobile.Comments.showUnloadedComments(this.link, this.bottomBar, this.commentActionLink);
      expect($(".show-comments").first()).toHaveClass("loading");
    });

    it("removes the 'loading' class if the request failed", function() {
      Diaspora.Mobile.Comments.showUnloadedComments(this.link, this.bottomBar, this.commentActionLink);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect($(".show-comments").first()).not.toHaveClass("loading");
    });

    it("adds the 'active' class if the request succeeded", function() {
      Diaspora.Mobile.Comments.showUnloadedComments(this.link, this.bottomBar, this.commentActionLink);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, contentType: "text/plain", responseText: "test"});
      expect($(".show-comments").first()).toHaveClass("active");
      expect($(".show-comments").first()).not.toHaveClass("loading");
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
      expect($(".stream .stream-element").first()).toContainElement(".commentContainerForTest");
    });

    it("shows and hides the mobile spinner", function(){
      Diaspora.Mobile.Comments.showComments(this.link);
      expect($(".ajax-loader").first()).toBeVisible();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, contentType: "text/plain", responseText: "test"});
      expect($(".ajax-loader").first()).not.toBeVisible();
    });
  });

  describe("submitComment", function() {
    beforeEach(function() {
      Diaspora.Mobile.Comments.initialize();
      Diaspora.Mobile.Comments.showCommentBox($(".stream .comment-action").first());
    });

    it("doesn't submit an empty comment", function() {
      $(".stream .new-comment").first().submit();
      expect(jasmine.Ajax.requests.count()).toBe(0);
    });

    it("submits comments with text", function() {
      $(".stream .new-comment textarea").val("comment text");
      $(".stream .new-comment").first().submit();
      expect(jasmine.Ajax.requests.mostRecent().data().text).toEqual(["comment text"]);
    });

    it("calls updateStream on success", function() {
      spyOn(Diaspora.Mobile.Comments, "updateStream");
      $(".stream .new-comment textarea").val("comment text");
      $(".stream .new-comment").first().submit();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 200, responseText: "foo"});
      expect(Diaspora.Mobile.Comments.updateStream).toHaveBeenCalledWith($(".stream .new-comment").first(), "foo");
    });

    it("lets Diaspora.Mobile.Alert handle AJAX errors", function() {
      spyOn(Diaspora.Mobile.Alert, "handleAjaxError");
      $(".stream .new-comment textarea").val("comment text");
      $(".stream .new-comment").first().submit();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "oh noez! comment failed!"});
      expect(Diaspora.Mobile.Alert.handleAjaxError).toHaveBeenCalled();
      expect(Diaspora.Mobile.Alert.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("oh noez! comment failed!");
    });

    it("calls resetCommentBox on errors", function() {
      spyOn(Diaspora.Mobile.Comments, "resetCommentBox");
      $(".stream .new-comment textarea").val("comment text");
      $(".stream .new-comment").first().submit();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "oh noez! comment failed!"});
      expect(Diaspora.Mobile.Comments.resetCommentBox).toHaveBeenCalledWith($(".stream .new-comment").first());
    });
  });

  describe("increaseReactionCount", function(){
    beforeEach(function() {
      this.toggleReactionsLink = this.bottomBar.find(".show-comments").first();
    });

    it("Increase reaction count from 1", function(){
      expect(this.toggleReactionsLink.text().trim()).toBe("5 comments");
      Diaspora.Mobile.Comments.increaseReactionCount(this.bottomBar);
      expect(this.toggleReactionsLink.text().trim()).toBe("6 comments");
    });

    it("Creates the reaction link when there are no reactions", function() {
      var parent = this.toggleReactionsLink.parent();
      var postGuid = this.bottomBar.parents(".stream-element").data("guid");
      this.toggleReactionsLink.remove();
      parent.prepend($("<span/>", {"class": "show-comments"}).text("0 comments"));

      Diaspora.Mobile.Comments.increaseReactionCount(this.bottomBar);
      this.toggleReactionsLink = this.bottomBar.find(".show-comments").first();
      expect(this.toggleReactionsLink.text().trim()).toBe("1 comment");
      expect(this.toggleReactionsLink.attr("href")).toBe("/posts/" + postGuid + "/comments.mobile");
    });

    it("Creates the reaction link when there are no reactions (french locale)", function() {
      var parent = this.toggleReactionsLink.parent();
      var postGuid = this.bottomBar.parents(".stream-element").data("guid");
      this.toggleReactionsLink.remove();
      parent.prepend($("<span/>", {"class": "show-comments"}).text("Aucun commentaire"));

      Diaspora.Mobile.Comments.increaseReactionCount(this.bottomBar);
      this.toggleReactionsLink = this.bottomBar.find(".show-comments").first();
      expect(this.toggleReactionsLink.text().trim()).toBe("1 comment");
      expect(this.toggleReactionsLink.attr("href")).toBe("/posts/" + postGuid + "/comments.mobile");
    });
  });

  describe("bottomBarLazy", function(){
    beforeEach(function() {
      this.bottomBarLazy = Diaspora.Mobile.Comments.bottomBarLazy(this.bottomBar);
    });

    it("shows and hides the loader", function(){
      expect(this.bottomBarLazy.loader()).toHaveClass("hidden");
      this.bottomBarLazy.showLoader();
      expect(this.bottomBarLazy.loader()).not.toHaveClass("hidden");
      this.bottomBarLazy.hideLoader();
      expect(this.bottomBarLazy.loader()).toHaveClass("hidden");
    });

    it("activates the bottom bar", function(){
      expect(this.bottomBar).toHaveClass("inactive");
      expect(this.bottomBar).not.toHaveClass("active");
      expect(this.bottomBarLazy.getShowCommentsLink()).not.toHaveClass("active");
      expect(this.bottomBarLazy.getShowCommentsLink().find("i")).toHaveClass("entypo-chevron-down");
      this.bottomBarLazy.activate();
      expect(this.bottomBar).not.toHaveClass("inactive");
      expect(this.bottomBar).toHaveClass("active");
      expect(this.bottomBarLazy.getShowCommentsLink()).toHaveClass("active");
      expect(this.bottomBarLazy.getShowCommentsLink().find("i")).toHaveClass("entypo-chevron-up");
    });

    it("deactivates the bottom bar", function(){
      this.bottomBarLazy.activate();
      expect(this.bottomBar).not.toHaveClass("inactive");
      expect(this.bottomBar).toHaveClass("active");
      expect(this.bottomBarLazy.getShowCommentsLink()).toHaveClass("active");
      expect(this.bottomBarLazy.getShowCommentsLink().find("i")).toHaveClass("entypo-chevron-up");
      this.bottomBarLazy.deactivate();
      expect(this.bottomBar).toHaveClass("inactive");
      expect(this.bottomBar).not.toHaveClass("active");
      expect(this.bottomBarLazy.getShowCommentsLink()).not.toHaveClass("active");
      expect(this.bottomBarLazy.getShowCommentsLink().find("i")).toHaveClass("entypo-chevron-down");
    });
  });
});
