describe("app.views.ConversationsForm", function() {
  beforeEach(function() {
    spec.loadFixture("conversations_read");
    this.target = new app.views.ConversationsForm();
  });

  describe("initialize", function() {
    it("initializes the conversation participants list", function() {
      expect(this.target.conversationRecipients).toEqual([]);
    });

    it("initializes the search view", function() {
      spyOn(app.views.SearchBase.prototype, "initialize");
      this.target.initialize();
      expect(app.views.SearchBase.prototype.initialize).toHaveBeenCalled();
      expect(app.views.SearchBase.prototype.initialize.calls.argsFor(0)[0].customSearch).toBe(true);
      expect(app.views.SearchBase.prototype.initialize.calls.argsFor(0)[0].autoselect).toBe(true);
      expect(app.views.SearchBase.prototype.initialize.calls.argsFor(0)[0].remoteRoute).toEqual({
        url: "/contacts",
        extraParameters: "mutual=true"
      });
      expect(this.target.search).toBeDefined();
    });

    it("calls bindTypeaheadEvents", function() {
      spyOn(app.views.ConversationsForm.prototype, "bindTypeaheadEvents");
      this.target.initialize();
      expect(app.views.ConversationsForm.prototype.bindTypeaheadEvents).toHaveBeenCalled();
    });

    it("calls prefill correctly", function() {
      spyOn(app.views.ConversationsForm.prototype, "prefill");
      this.target.initialize();
      expect(app.views.ConversationsForm.prototype.prefill).not.toHaveBeenCalled();
      this.target.initialize({prefill: {}});
      expect(app.views.ConversationsForm.prototype.prefill).toHaveBeenCalledWith({});
    });

    it("creates markdown editor for new conversations", function() {
      spyOn(this.target, "renderMarkdownEditor");
      this.target.initialize();
      expect(this.target.renderMarkdownEditor).toHaveBeenCalledWith("#new-message-text");
    });
  });

  describe("renderMarkdownEditor", function() {
    it("creates MarkdownEditor", function() {
      spec.content().html("<form><textarea id='new-message-text'/></form>");
      var mdEditor = this.target.renderMarkdownEditor("#new-message-text");
      expect(mdEditor).toEqual(jasmine.any(Diaspora.MarkdownEditor));
      expect($("#new-message-text")).toHaveClass("md-input");
    });
  });

  describe("addRecipient", function() {
    beforeEach(function() {
      $("#conversation-new").removeClass("hidden");
      $("#conversation-show").addClass("hidden");
    });

    it("adds the participant", function() {
      expect(this.target.conversationRecipients).toEqual([]);
      this.target.addRecipient({name: "diaspora user", handle: "diaspora-user@pod.tld"});
      expect(this.target.conversationRecipients).toEqual([{name: "diaspora user", handle: "diaspora-user@pod.tld"}]);
    });

    it("calls updateContactIdsListInput", function() {
      spyOn(app.views.ConversationsForm.prototype, "updateContactIdsListInput");
      this.target.addRecipient({name: "diaspora user", handle: "diaspora-user@pod.tld"});
      expect(app.views.ConversationsForm.prototype.updateContactIdsListInput).toHaveBeenCalled();
    });

    it("adds a recipient tag", function() {
      expect($(".conversation-recipient-tag").length).toBe(0);
      this.target.addRecipient({name: "diaspora user", handle: "diaspora-user@pod.tld"});
      expect($(".conversation-recipient-tag").length).toBe(1);
    });

    it("calls setupAvatarFallback", function() {
      spyOn(this.target, "setupAvatarFallback");
      this.target.addRecipient({name: "diaspora user", handle: "diaspora-user@pod.tld"});
      expect(this.target.setupAvatarFallback).toHaveBeenCalled();
    });
  });

  describe("prefill", function() {
    beforeEach(function() {
      this.prefills = [
        factory.personWithProfile({"diaspora_id": "alice@pod.tld"}),
        factory.personWithProfile({"diaspora_id": "bob@pod.tld"}),
        factory.personWithProfile({"diaspora_id": "carol@pod.tld"})
      ];
    });

    it("calls addRecipient for each prefilled participant", function() {
      spyOn(app.views.ConversationsForm.prototype, "addRecipient");
      this.target.prefill(this.prefills);
      expect(app.views.ConversationsForm.prototype.addRecipient).toHaveBeenCalledTimes(this.prefills.length);
      var allArgsFlattened = app.views.ConversationsForm.prototype.addRecipient.calls.allArgs().map(function(arg) {
        return arg[0];
      });

      expect(_.pluck(allArgsFlattened, "handle")).toEqual(
        this.prefills.map(function(person) { return person.get("diaspora_id"); })
      );

      expect(_.pluck(allArgsFlattened, "avatar")).toEqual(
        this.prefills.map(function(person) { return person.get("profile").avatar.small; })
      );
    });
  });

  describe("updateContactIdsListInput", function() {
    beforeEach(function() {
      this.target.conversationRecipients.push({id: 1, name: "diaspora user", handle: "diaspora-user@pod.tld"});
      this.target.conversationRecipients
        .push({id: 2, name: "other diaspora user", handle: "other-diaspora-user@pod.tld"});
      this.target.conversationRecipients.push({id: 3, name: "user@pod.tld", handle: "user@pod.tld"});
    });

    it("updates hidden input value", function() {
      this.target.updateContactIdsListInput();
      expect(this.target.contactsIdsListInput.val()).toBe("1,2,3");
    });

    it("calls app.views.SearchBase.ignorePersonForSuggestions() for each participant", function() {
      spyOn(app.views.SearchBase.prototype, "ignorePersonForSuggestions");
      this.target.updateContactIdsListInput();
      expect(app.views.SearchBase.prototype.ignorePersonForSuggestions).toHaveBeenCalledTimes(3);
      expect(app.views.SearchBase.prototype.ignorePersonForSuggestions.calls.argsFor(0)[0])
        .toEqual({id: 1, name: "diaspora user", handle: "diaspora-user@pod.tld"});
      expect(app.views.SearchBase.prototype.ignorePersonForSuggestions.calls.argsFor(1)[0])
        .toEqual({id: 2, name: "other diaspora user", handle: "other-diaspora-user@pod.tld"});
      expect(app.views.SearchBase.prototype.ignorePersonForSuggestions.calls.argsFor(2)[0])
        .toEqual({id: 3, name: "user@pod.tld", handle: "user@pod.tld"});
    });
  });

  describe("bindTypeaheadEvents", function() {
    it("calls onSuggestionSelection() when clicking on a result", function() {
      spyOn(app.views.ConversationsForm.prototype, "onSuggestionSelection");
      var event = $.Event("typeahead:select");
      var person = {name: "diaspora user"};
      this.target.typeaheadElement.trigger(event, [person]);
      expect(app.views.ConversationsForm.prototype.onSuggestionSelection).toHaveBeenCalledWith(person);
    });
  });

  describe("onSuggestionSelection", function() {
    it("calls addRecipient and $.fn.typeahead", function() {
      spyOn(app.views.ConversationsForm.prototype, "addRecipient");
      spyOn($.fn, "typeahead");
      var person = {name: "diaspora user"};
      this.target.onSuggestionSelection(person);
      expect(app.views.ConversationsForm.prototype.addRecipient).toHaveBeenCalledWith(person);
      expect($.fn.typeahead).toHaveBeenCalledWith("val", "");
    });
  });

  describe("keyDown", function() {
    beforeEach(function() {
      this.submitCallback = jasmine.createSpy().and.returnValue(false);
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

      it("should submit the form with cmd+enter", function() {
        $("#new-conversation").submit(this.submitCallback);
        var e = $.Event("keydown", {which: Keycodes.ENTER, metaKey: true});
        $("#new-message-text").trigger(e);
        expect(this.submitCallback).toHaveBeenCalled();
      });

      it("shouldn't submit the form without the ctrl or cmd key", function() {
        $("#new-conversation").submit(this.submitCallback);
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: false, metaKey: false});
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

      it("should submit the form with cmd+enter", function() {
        $("#response-message").submit(this.submitCallback);
        var e = $.Event("keydown", {which: Keycodes.ENTER, metaKey: true});
        $("#response-message-text").trigger(e);
        expect(this.submitCallback).toHaveBeenCalled();
      });

      it("shouldn't submit the form without the ctrl or cmd key", function() {
        $("#response-message").submit(this.submitCallback);
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: false, metaKey: false});
        $("#response-message-text").trigger(e);
        expect(this.submitCallback).not.toHaveBeenCalled();
      });
    });
  });

  describe("removeRecipient", function() {
    beforeEach(function() {
      this.target.addRecipient({id: 1, name: "diaspora user", handle: "diaspora-user@pod.tld"});
      this.target.addRecipient({id: 2, name: "other diaspora user", handle: "other-diaspora-user@pod.tld"});
      this.target.addRecipient({id: 3, name: "user@pod.tld", handle: "user@pod.tld"});
    });

    it("removes the user from conversation recipients when clicking the tag's remove button", function() {
      expect(this.target.conversationRecipients).toEqual([
        {id: 1, name: "diaspora user", handle: "diaspora-user@pod.tld"},
        {id: 2, name: "other diaspora user", handle: "other-diaspora-user@pod.tld"},
        {id: 3, name: "user@pod.tld", handle: "user@pod.tld"}
      ]);

      $("[data-diaspora-handle='diaspora-user@pod.tld'] .remove").click();

      expect(this.target.conversationRecipients).toEqual([
        {id: 2, name: "other diaspora user", handle: "other-diaspora-user@pod.tld"},
        {id: 3, name: "user@pod.tld", handle: "user@pod.tld"}
      ]);

      $("[data-diaspora-handle='other-diaspora-user@pod.tld'] .remove").click();

      expect(this.target.conversationRecipients).toEqual([
        {id: 3, name: "user@pod.tld", handle: "user@pod.tld"}
      ]);

      $("[data-diaspora-handle='user@pod.tld'] .remove").click();

      expect(this.target.conversationRecipients).toEqual([]);
    });

    it("removes the tag element when clicking the tag's remove button", function() {
      expect($("[data-diaspora-handle='diaspora-user@pod.tld']").length).toBe(1);
      $("[data-diaspora-handle='diaspora-user@pod.tld'] .remove").click();
      expect($("[data-diaspora-handle='diaspora-user@pod.tld']").length).toBe(0);

      expect($("[data-diaspora-handle='other-diaspora-user@pod.tld']").length).toBe(1);
      $("[data-diaspora-handle='other-diaspora-user@pod.tld'] .remove").click();
      expect($("[data-diaspora-handle='other-diaspora-user@pod.tld']").length).toBe(0);

      expect($("[data-diaspora-handle='user@pod.tld']").length).toBe(1);
      $("[data-diaspora-handle='user@pod.tld'] .remove").click();
      expect($("[data-diaspora-handle='user@pod.tld']").length).toBe(0);
    });

    it("calls updateContactIdsListInput", function() {
      spyOn(app.views.ConversationsForm.prototype, "updateContactIdsListInput");
      $("[data-diaspora-handle='diaspora-user@pod.tld'] .remove").click();
      expect(app.views.ConversationsForm.prototype.updateContactIdsListInput).toHaveBeenCalled();
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

    it("hides the preview", function() {
      spyOn(Diaspora.MarkdownEditor.prototype, "hidePreview");
      $("#new-conversation").trigger("ajax:success", [{id: 23}]);
      expect(Diaspora.MarkdownEditor.prototype.hidePreview).toHaveBeenCalled();
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
