describe("app.views.CommentStream", function(){
  beforeEach(function(){
    this.view = new app.views.CommentStream({model : factory.post()});
    loginAs({});
  });

  describe("binds", function() {
    it("re-renders on a commentsExpanded trigger", function(){
      spyOn(this.view, "render");
      this.view.setupBindings();
      this.view.model.trigger("commentsExpanded");
      expect(this.view.render).toHaveBeenCalled();
    });
  });

  describe("postRenderTemplate", function(){
    it("autoResizes the new comment textarea", function(){
      spyOn(window, "autosize");
      this.view.postRenderTemplate();
      expect(window.autosize).toHaveBeenCalled();
      expect(window.autosize.calls.mostRecent().args[0].selector).toBe("textarea");
    });
  });

  describe("createComment", function() {
    beforeEach(function() {
      this.view.render();
      this.view.$el.append($("<div id='flash-container'/>"));
      app.flashMessages = new app.views.FlashMessages({ el: this.view.$("#flash-container") });
      this.view.expandComments();
    });

    context("submission", function() {
      beforeEach(function() {
        this.view.$(".comment_box").val('a new comment');
        this.view.createComment();

        this.request = jasmine.Ajax.requests.mostRecent();
      });

      it("fires an AJAX request", function() {
        var params = this.request.data();

        expect(params.text).toEqual("a new comment");
      });

      it("adds the comment to the view", function() {
        this.request.respondWith({status: 200, responseText: '[]'});
        expect(this.view.$(".comment-content p").text()).toEqual("a new comment");
      });

      it("doesn't add the comment to the view, when the request fails", function(){
        Diaspora.I18n.load({failed_to_post_message: "posting failed!"});
        this.request.respondWith({status: 500});

        expect(this.view.$(".comment-content p").text()).not.toEqual("a new comment");
        expect(this.view.$(".flash-message")).toBeErrorFlashMessage("posting failed!");
      });
    });

    it("clears the comment box when there are only spaces", function() {
      this.view.$(".comment_box").val('   ');
      this.view.createComment();
      expect(this.view.$(".comment_box").val()).toEqual("");
    });

    it("resets comment box height", function() {
      this.view.$(".comment_box").val('a new comment');
      this.view.createComment();
      expect(this.view.$(".comment_box").attr("style")).not.toContain("height");
    });
  });

  describe("appendComment", function(){
    it("appends this.model as 'parent' to the comment", function(){
      var comment = factory.comment();
      spyOn(comment, "set");
      this.view.appendComment(comment);
      expect(comment.set).toHaveBeenCalled();
    });
  });

  describe("expandComments", function() {
    it("refills the comment textbox on success", function() {
      this.view.render();
      this.view.$("textarea").val("great post!");
      this.view.expandComments();

      jasmine.Ajax.requests.mostRecent().respondWith({ comments : [] });

      expect(this.view.$("textarea").val()).toEqual("great post!");
    });
  });

  describe("pressing a key when typing on the new comment box", function(){
    var submitCallback;

    beforeEach(function() {
      submitCallback = jasmine.createSpy().and.returnValue(false);
    });

    it("should not submit the form when enter key is pressed", function(){
      this.view.render();
      var form = this.view.$("form");
      form.submit(submitCallback);

      var e = $.Event("keydown", { keyCode: 13 });
      e.ctrlKey = false;
      this.view.keyDownOnCommentBox(e);

      expect(submitCallback).not.toHaveBeenCalled();
    });

    it("should submit the form when enter is pressed with ctrl", function(){
      this.view.render();
      var form = this.view.$("form");
      form.submit(submitCallback);

      var e = $.Event("keydown", { keyCode: 13 });
      e.ctrlKey = true;
      this.view.keyDownOnCommentBox(e);

      expect(submitCallback).toHaveBeenCalled();
    });
  });

});
