describe("Diaspora.Mobile.Conversations", function() {
  beforeEach(function() {
    spec.loadFixture("conversations_new_mobile");
    Diaspora.Page = "ConversationsNew";
  });

  afterEach(function() {
    $(document).off("ajax:success", Diaspora.Mobile.Conversations.conversationCreateSuccess);
    $(document).off("ajax:error", Diaspora.Mobile.Conversations.conversationCreateError);
  });

  describe("conversationCreateSuccess", function() {
    it("is called when there was a successful ajax request for the conversation form", function() {
      spyOn(Diaspora.Mobile.Conversations, "conversationCreateSuccess");
      Diaspora.Mobile.Conversations.initialize();

      $("#flash-messages").trigger("ajax:success", [{id: 23}]);
      expect(Diaspora.Mobile.Conversations.conversationCreateSuccess).not.toHaveBeenCalled();

      $("#new-conversation").trigger("ajax:error", [{responseText: "error"}]);
      expect(Diaspora.Mobile.Conversations.conversationCreateSuccess).not.toHaveBeenCalled();

      $("#new-conversation").trigger("ajax:success", [{id: 23}]);
      expect(Diaspora.Mobile.Conversations.conversationCreateSuccess).toHaveBeenCalled();
    });

    it("redirects to the new conversation", function() {
      spyOn(Diaspora.Mobile, "changeLocation");
      Diaspora.Mobile.Conversations.initialize();
      $("#new-conversation").trigger("ajax:success", [{id: 23}]);
      expect(Diaspora.Mobile.changeLocation).toHaveBeenCalledWith(Routes.conversation(23));
    });
  });

  describe("conversationCreateError", function() {
    it("is called when an ajax request failed for the conversation form", function() {
      spyOn(Diaspora.Mobile.Conversations, "conversationCreateError");
      Diaspora.Mobile.Conversations.initialize();

      $("#flash-messages").trigger("ajax:error", [{responseText: "error"}]);
      expect(Diaspora.Mobile.Conversations.conversationCreateError).not.toHaveBeenCalled();

      $("#new-conversation").trigger("ajax:success", [{id: 23}]);
      expect(Diaspora.Mobile.Conversations.conversationCreateError).not.toHaveBeenCalled();

      $("#new-conversation").trigger("ajax:error", [{responseText: "error"}]);
      expect(Diaspora.Mobile.Conversations.conversationCreateError).toHaveBeenCalled();
    });

    it("shows a flash message", function() {
      spyOn(Diaspora.Mobile.Alert, "handleAjaxError").and.callThrough();
      Diaspora.Mobile.Conversations.initialize();
      var response = {status: 422, responseText: "Oh noez! Something went wrong!"};
      $("#new-conversation").trigger("ajax:error", response);
      expect(Diaspora.Mobile.Alert.handleAjaxError).toHaveBeenCalledWith(response);
      expect($("#flash-messages")).toHaveText("Oh noez! Something went wrong!");
    });
  });
});
