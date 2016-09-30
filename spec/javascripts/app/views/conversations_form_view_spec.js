describe("app.views.ConversationsForm", function() {
  beforeEach(function() {
    spec.loadFixture("conversations_read");
  });

  describe("keyDown", function() {
    beforeEach(function() {
      this.submitCallback = jasmine.createSpy().and.returnValue(false);
      new app.views.ConversationsForm();
    });

    context("on new message form", function() {
      beforeEach(function() {
        $("#conversation-new").removeClass("hidden");
        $("#conversation-show").addClass("hidden");
      });

      it("should submit the form with ctrl+enter", function() {
        $("#new-conversation").submit(this.submitCallback);
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: true});
        $("#new-message-text").trigger(e);
        expect(this.submitCallback).toHaveBeenCalled();
      });

      it("shouldn't submit the form without the ctrl key", function() {
        $("#new-conversation").submit(this.submitCallback);
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: false});
        $("#new-message-text").trigger(e);
        expect(this.submitCallback).not.toHaveBeenCalled();
      });
    });

    context("on response message form", function() {
      beforeEach(function() {
        $("#conversation-new").addClass("hidden");
        $("#conversation-show").removeClass("hidden");
      });

      it("should submit the form with ctrl+enter", function() {
        $("#response-message").submit(this.submitCallback);
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: true});
        $("#response-message-text").trigger(e);
        expect(this.submitCallback).toHaveBeenCalled();
      });

      it("shouldn't submit the form without the ctrl key", function() {
        $("#response-message").submit(this.submitCallback);
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: false});
        $("#response-message-text").trigger(e);
        expect(this.submitCallback).not.toHaveBeenCalled();
      });
    });
  });

  describe("conversationCreateSuccess", function() {
    it("is called when there was a successful ajax request for the conversation form", function() {
      spyOn(app.views.ConversationsForm.prototype, "conversationCreateSuccess");
      this.view = new app.views.ConversationsForm();

      $("#conversation-show").trigger("ajax:success", [{id: 23}]);
      expect(app.views.ConversationsForm.prototype.conversationCreateSuccess).not.toHaveBeenCalled();

      $("#new-conversation").trigger("ajax:error", [{responseText: "error"}]);
      expect(app.views.ConversationsForm.prototype.conversationCreateSuccess).not.toHaveBeenCalled();

      $("#new-conversation").trigger("ajax:success", [{id: 23}]);
      expect(app.views.ConversationsForm.prototype.conversationCreateSuccess).toHaveBeenCalled();
    });

    it("redirects to the new conversation", function() {
      spyOn(app, "_changeLocation");
      this.view = new app.views.ConversationsForm();
      $("#new-conversation").trigger("ajax:success", [{id: 23}]);
      expect(app._changeLocation).toHaveBeenCalledWith(Routes.conversation(23));
    });
  });

  describe("conversationCreateError", function() {
    it("is called when an ajax request failed for the conversation form", function() {
      spyOn(app.views.ConversationsForm.prototype, "conversationCreateError");
      this.view = new app.views.ConversationsForm();

      $("#conversation-show").trigger("ajax:error", [{responseText: "error"}]);
      expect(app.views.ConversationsForm.prototype.conversationCreateError).not.toHaveBeenCalled();

      $("#new-conversation").trigger("ajax:success", [{id: 23}]);
      expect(app.views.ConversationsForm.prototype.conversationCreateError).not.toHaveBeenCalled();

      $("#new-conversation").trigger("ajax:error", [{responseText: "error"}]);
      expect(app.views.ConversationsForm.prototype.conversationCreateError).toHaveBeenCalled();
    });

    it("shows a flash message", function() {
      spyOn(app.flashMessages, "error");
      this.view = new app.views.ConversationsForm();
      $("#new-conversation").trigger("ajax:error", [{responseText: "Oh noez! Something went wrong!"}]);
      expect(app.flashMessages.error).toHaveBeenCalledWith("Oh noez! Something went wrong!");
    });
  });
});
