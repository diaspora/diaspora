describe("app.views.CommentStream", function(){
  beforeEach(function(){
    this.view = new app.views.CommentStream({model : factory.post()});
    loginAs({});
  });

  describe("binds", function() {
    it("calls appendComment on insertion to the comments collection", function() {
      spyOn(this.view, "appendComment");
      this.view.setupBindings();
      this.view.model.comments.push(factory.comment());
      expect(this.view.appendComment).toHaveBeenCalled();
    });

    it("calls removeComment on removal from the comments collection", function() {
      this.view.model.comments.push(factory.comment());
      spyOn(this.view, "removeComment");
      this.view.setupBindings();
      this.view.model.comments.pop();
      expect(this.view.removeComment).toHaveBeenCalled();
    });
  });

  describe("postRenderTemplate", function() {
    beforeEach(function() {
      this.view.render();
    });

    it("calls appendComment for all comments in the collection", function() {
      this.view.model.comments.push(factory.comment({id: 1}));
      this.view.model.comments.push(factory.comment({id: 27}));
      this.view.model.comments.push(factory.comment({id: 3}));
      spyOn(this.view, "appendComment");
      this.view.postRenderTemplate();
      expect(this.view.appendComment.calls.allArgs().map(function(args) {
        return args[0].get("id");
      })).toEqual([1, 27, 3]);
    });

    it("sets commentBox", function() {
      this.view.commentBox = undefined;
      this.view.postRenderTemplate();
      expect(this.view.commentBox).toBeDefined();
      expect(this.view.commentBox).toEqual(this.view.$(".comment_box"));
    });

    it("sets commentSubmitButton", function() {
      this.view.commentSubmitButton = undefined;
      this.view.postRenderTemplate();
      expect(this.view.commentSubmitButton).toBeDefined();
      expect(this.view.commentSubmitButton).toEqual(this.view.$("input[name='commit']"));
    });
  });

  describe("createComment", function() {
    beforeEach(function() {
      this.view.render();
      this.view.$el.append($("<div id='flash-container'/>"));
      app.flashMessages = new app.views.FlashMessages({ el: this.view.$("#flash-container") });
      this.view.expandComments();
    });

    it("doesn't fire an AJAX request when there are only spaces in the comment box", function() {
      this.view.commentBox.val("   ");
      jasmine.Ajax.requests.reset();
      this.view.createComment();
      expect(jasmine.Ajax.requests.count()).toBe(0);
    });

    it("calls disableCommentBox", function() {
      spyOn(this.view, "disableCommentBox");
      this.view.commentBox.val("text");
      this.view.createComment();
      expect(this.view.disableCommentBox).toHaveBeenCalled();
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

      context("on success", function() {
        it("adds the comment to the view", function() {
          this.request.respondWith({status: 200, responseText: "[]"});
          expect(this.view.$(".comment-content p").text()).toEqual("a new comment");
        });

        it("resets the comment box value", function() {
          this.request.respondWith({status: 200, responseText: "[]"});
          expect(this.view.commentBox.val()).toBe("");
        });

        it("calls enableCommentBox", function() {
          spyOn(this.view, "enableCommentBox");
          this.request.respondWith({status: 200, responseText: "[]"});
          expect(this.view.enableCommentBox).toHaveBeenCalled();
        });

        it("calls autosize.update for the commentBox", function() {
          spyOn(autosize, "update");
          this.request.respondWith({status: 200, responseText: "[]"});
          expect(autosize.update).toHaveBeenCalledWith(this.view.commentBox);
        });
      });

      context("on error", function() {
        it("doesn't add the comment to the view", function() {
          this.request.respondWith({status: 500});
          expect(this.view.$(".comment-content p").text()).not.toEqual("a new comment");
        });

        it("doesn't reset the comment box value", function() {
          this.request.respondWith({status: 500});
          expect(this.view.commentBox.val()).toBe("a new comment");
        });

        it("calls enableCommentBox", function() {
          spyOn(this.view, "enableCommentBox");
          this.request.respondWith({status: 500});
          expect(this.view.enableCommentBox).toHaveBeenCalled();
        });
      });
    });
  });

  describe("disableCommentBox", function() {
    beforeEach(function() {
      this.view.render();
    });

    it("disables the comment box", function() {
      this.view.commentBox.removeAttr("disabled");
      this.view.disableCommentBox();
      expect(this.view.commentBox.prop("disabled")).toBeTruthy();
    });

    it("disables the comment submit button", function() {
      this.view.commentSubmitButton.removeAttr("disabled");
      this.view.disableCommentBox();
      expect(this.view.commentSubmitButton.prop("disabled")).toBeTruthy();
    });
  });

  describe("enableCommentBox", function() {
    beforeEach(function() {
      this.view.render();
    });

    it("removes the 'disabled' attribute from the comment box", function() {
      this.view.commentBox.prop("disabled", true);
      this.view.enableCommentBox();
      expect(this.view.commentBox.prop("disabled")).toBeFalsy();
    });

    it("removes the 'disabled' attribute from the comment submit button", function() {
      this.view.commentSubmitButton.prop("disabled", true);
      this.view.enableCommentBox();
      expect(this.view.commentSubmitButton.prop("disabled")).toBeFalsy();
    });
  });

  describe("appendComment", function(){
    it("appends this.model as 'parent' to the comment", function(){
      var comment = factory.comment();
      spyOn(comment, "set");
      this.view.appendComment(comment);
      expect(comment.set).toHaveBeenCalled();
    });

    it("uses this.CommentView for the Comment view", function() {
      var comment = factory.comment();
      this.view.CommentView = app.views.Comment;
      spyOn(app.views.Comment.prototype, "initialize");
      this.view.appendComment(comment);
      expect(app.views.Comment.prototype.initialize).toHaveBeenCalled();

      this.view.CommentView = app.views.StatusMessage;
      spyOn(app.views.StatusMessage.prototype, "initialize");
      this.view.appendComment(comment);
      expect(app.views.StatusMessage.prototype.initialize).toHaveBeenCalled();
    });

    it("sorts comments in the right order", function() {
      this.view.render();
      this.view.appendComment(factory.comment({"created_at": new Date(2000).toJSON(), "text": "2"}));
      this.view.appendComment(factory.comment({"created_at": new Date(4000).toJSON(), "text": "4"}));
      this.view.appendComment(factory.comment({"created_at": new Date(5000).toJSON(), "text": "5"}));
      this.view.appendComment(factory.comment({"created_at": new Date(6000).toJSON(), "text": "6"}));
      this.view.appendComment(factory.comment({"created_at": new Date(1000).toJSON(), "text": "1"}));
      this.view.appendComment(factory.comment({"created_at": new Date(3000).toJSON(), "text": "3"}));

      expect(this.view.$(".comments div.comment.media").length).toEqual(6);
      expect(this.view.$(".comments div.comment.media div.comment-content p").text()).toEqual("123456");
    });
  });

  describe("removeComment", function() {
    it("removes the comment from the stream", function() {
      this.view.model.comments.push(factory.comment());
      this.view.model.comments.push(factory.comment());
      var comment = factory.comment();
      this.view.model.comments.push(comment);
      this.view.model.comments.push(factory.comment());
      this.view.render();
      expect(this.view.$(".comments div.comment.media").length).toBe(4);
      expect(this.view.$("#" + comment.get("guid")).length).toBe(1);
      this.view.removeComment(comment);
      expect(this.view.$(".comments div.comment.media").length).toBe(3);
      expect(this.view.$("#" + comment.get("guid")).length).toBe(0);
    });
  });

  describe("expandComments", function() {
    it("doesn't drop the comment textbox value on success", function() {
      this.view.render();
      this.view.$("textarea").val("great post!");
      this.view.expandComments();

      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: JSON.stringify([factory.comment()])
      });

      expect(this.view.$("textarea").val()).toEqual("great post!");
    });

    it("adds and removes comments in the right order", function() {
      var comments = _.range(42).map(function(_, index) {
        return factory.comment({"text": "" + index, "created_at": new Date(index).toJSON()});
      });
      var evenComments = comments.filter(function(_, index) { return index % 2 === 0; });
      this.view.model.comments.reset(evenComments);
      this.view.render();
      expect(this.view.$(".comments div.comment.media").length).toBe(21);
      expect(this.view.$(".comments div.comment.media div.comment-content p").text()).toEqual(
        evenComments.map(function(c) { return c.get("text"); }).join("")
      );

      var randomComments = _.shuffle(comments).slice(0, 23);
      this.view.expandComments();
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: JSON.stringify(randomComments)
      });

      expect(this.view.$(".comments div.comment.media").length).toBe(23);
      expect(this.view.$(".comments div.comment.media div.comment-content p").text()).toEqual(
        _.sortBy(randomComments, function(c) {
          return c.get("created_at");
        }).map(function(c) {
          return c.get("text");
        }).join("")
      );
    });

    it("shows the spinner when loading comments and removes it on success", function() {
      this.view.render();
      expect(this.view.$(".loading-comments")).toHaveClass("hidden");

      this.view.expandComments();
      expect(this.view.$(".loading-comments")).not.toHaveClass("hidden");

      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200, responseText: JSON.stringify([])
      });
      expect(this.view.$(".loading-comments")).toHaveClass("hidden");
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

      var e = $.Event("keydown", { which: Keycodes.ENTER, ctrlKey: false });
      this.view.keyDownOnCommentBox(e);

      expect(submitCallback).not.toHaveBeenCalled();
    });

    it("should submit the form when enter is pressed with ctrl", function(){
      this.view.render();
      var form = this.view.$("form");
      form.submit(submitCallback);

      var e = $.Event("keydown", { which: Keycodes.ENTER, ctrlKey: true });
      this.view.keyDownOnCommentBox(e);

      expect(submitCallback).toHaveBeenCalled();
    });
  });
});
