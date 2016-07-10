describe("app.views.ConversationsForm", function() {
  describe("keyDown", function() {
    beforeEach(function() {
      this.submitCallback = jasmine.createSpy().and.returnValue(false);
      spec.loadFixture("conversations_read");
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

  describe("onSubmitNewConversation", function() {
    beforeEach(function() {
      spec.loadFixture("conversations_read");
      $("#conversation-new").removeClass("hidden");
      $("#conversation-show").addClass("hidden");
      spyOn(app.views.ConversationsForm.prototype, "onSubmitNewConversation").and.callThrough();
      this.target = new app.views.ConversationsForm();
    });

    it("onSubmitNewConversation is called when submitting the conversation form", function() {
      spyOn(app.views.ConversationsForm.prototype, "getConversationParticipants").and.returnValue([]);
      $("#conversation-new").trigger("submit");

      expect(app.views.ConversationsForm.prototype.onSubmitNewConversation).toHaveBeenCalled();
    });

    it("does not submit a conversation with no recipient", function() {
      spyOn(app.views.ConversationsForm.prototype, "getConversationParticipants").and.returnValue([]);
      var event = jasmine.createSpyObj("event", ["preventDefault", "stopPropagation"]);

      this.target.onSubmitNewConversation(event);

      expect(event.preventDefault).toHaveBeenCalled();
      expect(event.stopPropagation).toHaveBeenCalled();
    });

    it("submits a conversation with recipients", function() {
      spyOn(app.views.ConversationsForm.prototype, "getConversationParticipants").and.returnValue([1]);
      var event = jasmine.createSpyObj("event", ["preventDefault", "stopPropagation"]);

      this.target.onSubmitNewConversation(event);

      expect(event.preventDefault).toHaveBeenCalled();
      expect(event.stopPropagation).not.toHaveBeenCalled();
    });

    it("flashes an error message when submitting a conversation with no recipient", function() {
      spyOn(app.views.FlashMessages.prototype, "error");
      spyOn(app.views.ConversationsForm.prototype, "getConversationParticipants").and.returnValue([]);
      var event = jasmine.createSpyObj("event", ["preventDefault", "stopPropagation"]);

      this.target.onSubmitNewConversation(event);

      expect(app.views.FlashMessages.prototype.error)
        .toHaveBeenCalledWith(Diaspora.I18n.t("conversation.create.no_recipient"));
    });

    it("does not flash an error message when submitting a conversation with recipients", function() {
      spyOn(app.views.FlashMessages.prototype, "error");
      spyOn(app.views.ConversationsForm.prototype, "getConversationParticipants").and.returnValue([1]);
      var event = jasmine.createSpyObj("event", ["preventDefault", "stopPropagation"]);

      this.target.onSubmitNewConversation(event);

      expect(app.views.FlashMessages.prototype.error).not
        .toHaveBeenCalledWith(Diaspora.I18n.t("conversation.create.no_recipient"));
    });
  });
});
