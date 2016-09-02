describe("app.view.ConversationsForm", function() {
  beforeEach(function() {
    spec.loadFixture("conversations_read");
    this.target = new app.views.ConversationsForm();
  });

  describe("initialize", function() {
    it("initializes the conversation participants list", function() {
      expect(this.target.conversationParticipants).toEqual([]);
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

    it("initializes the contacts tags element", function() {
      spyOn($.fn, "tags").and.callThrough();
      this.target.initialize();
      expect($.fn.tags).toHaveBeenCalled();
      expect($.fn.tags.calls.argsFor(0)[0].tagData).toEqual([]);
      expect($.fn.tags.calls.argsFor(0)[0].tagClass).toBe("btn-primary conversation-contact-tag");
      expect(this.target.contactsTags).toBeDefined();
    });

    it("calls bindTypeaheadEvents()", function() {
      spyOn(app.views.ConversationsForm.prototype, "bindTypeaheadEvents");
      this.target.initialize();
      expect(app.views.ConversationsForm.prototype.bindTypeaheadEvents).toHaveBeenCalled();
    });

    it("calls prefill() correctly", function() {
      spyOn(app.views.ConversationsForm.prototype, "prefill");
      this.target.initialize();
      expect(app.views.ConversationsForm.prototype.prefill).not.toHaveBeenCalled();
      this.target.initialize({prefills: {}});
      expect(app.views.ConversationsForm.prototype.prefill).toHaveBeenCalledWith({});
    });
  });

  describe("getTagFromPerson", function() {
    it("correctly formats the tag text", function() {
      expect(this.target.getTagFromPerson({name: "diaspora user", handle: "diaspora-user@pod.tld"}))
        .toBe("diaspora user \u200B(diaspora-user@pod.tld)");
    });

    it("correctly formats the tag text for a user with no nickname", function() {
      expect(this.target.getTagFromPerson({name: "user@pod.tld", handle: "user@pod.tld"}))
        .toBe("user@pod.tld");
    });

    it("correctly formats the tag text for a user with the unicode litteral marker in nickname", function() {
      expect(this.target.getTagFromPerson({name: "user with \u200B unicode litteral", handle: "user2@pod.tld"}))
        .toBe("user with  unicode litteral \u200B(user2@pod.tld)");
    });
  });

  describe("extractHandleFromTag", function() {
    it("extracts handle from tag for user", function() {
      expect(this.target.extractHandleFromTag("diaspora user \u200B(diaspora-user@pod.tld)"))
        .toBe("diaspora-user@pod.tld");
    });

    it("extracts handle from tag for user with no nickname", function() {
      expect(this.target.extractHandleFromTag("user@pod.tld")).toBe("user@pod.tld");
    });
  });

  describe("onDeleteTag", function() {
    beforeEach(function() {
      this.target.conversationParticipants.push({name: "diaspora user", handle: "diaspora-user@pod.tld"});
      this.target.conversationParticipants.push({name: "other diaspora user", handle: "other-diaspora-user@pod.tld"});
      this.target.conversationParticipants.push({name: "user@pod.tld", handle: "user@pod.tld"});
      this.target.conversationParticipants.push({name: "user with \u200B unicode litteral", handle: "user2@pod.tld"});
    });

    it("removes the person from the conversation participants", function() {
      expect(this.target.conversationParticipants).toEqual([
        {name: "diaspora user", handle: "diaspora-user@pod.tld"},
        {name: "other diaspora user", handle: "other-diaspora-user@pod.tld"},
        {name: "user@pod.tld", handle: "user@pod.tld"},
        {name: "user with \u200B unicode litteral", handle: "user2@pod.tld"}
      ]);
      // Nominal case
      this.target.onDeleteTag("diaspora user \u200B(diaspora-user@pod.tld)");
      expect(this.target.conversationParticipants).toEqual([
        {name: "other diaspora user", handle: "other-diaspora-user@pod.tld"},
        {name: "user@pod.tld", handle: "user@pod.tld"},
        {name: "user with \u200B unicode litteral", handle: "user2@pod.tld"}
      ]);
      // Case of user with no nickname
      this.target.onDeleteTag("user@pod.tld");
      expect(this.target.conversationParticipants).toEqual([
        {name: "other diaspora user", handle: "other-diaspora-user@pod.tld"},
        {name: "user with \u200B unicode litteral", handle: "user2@pod.tld"}
      ]);
      // Case of user with the unicode litteral marker
      this.target.onDeleteTag("user with  unicode litteral \u200B(user2@pod.tld)");
      expect(this.target.conversationParticipants).toEqual([
        {name: "other diaspora user", handle: "other-diaspora-user@pod.tld"}
      ]);
    });

    it("calls updateContactIdsListInput()", function() {
      spyOn(app.views.ConversationsForm.prototype, "updateContactIdsListInput");
      this.target.onDeleteTag("diaspora user \u200B(diaspora-user@pod.tld)");
      expect(app.views.ConversationsForm.prototype.updateContactIdsListInput).toHaveBeenCalled();
    });

    it("$.fn.tags correctly remove a conversation participant", function() {
      this.target.conversationParticipants.forEach(function(person) {
        this.target.contactsTags.addTag(person.name + " \u200B(" + person.handle + ")");
      }.bind(this));
      spyOn(app.views.ConversationsForm.prototype, "updateContactIdsListInput");
      $(".conversation-contact-tag a").first().click();
      expect(app.views.ConversationsForm.prototype.updateContactIdsListInput).toHaveBeenCalled();
      expect(this.target.conversationParticipants.length).toEqual(3);
    });
  });

  describe("prefill", function() {
    beforeEach(function() {
      this.prefills = [{name: "diaspora user"}, {name: "other diaspora user"}, {name: "user"}];
    });

    it("call addParticipant for each prefilled participant", function() {
      spyOn(app.views.ConversationsForm.prototype, "addParticipant");
      this.target.prefill(this.prefills);
      expect(app.views.ConversationsForm.prototype.addParticipant).toHaveBeenCalledTimes(this.prefills.length);
      var allArgsFlattened = app.views.ConversationsForm.prototype.addParticipant.calls.allArgs().map(function(arg) {
        return arg[0];
      });
      expect(allArgsFlattened).toEqual(this.prefills);
    });

    it("call updateContactIdsListInput", function() {
      spyOn(app.views.ConversationsForm.prototype, "updateContactIdsListInput");
      this.target.prefill(this.prefills);
      expect(app.views.ConversationsForm.prototype.updateContactIdsListInput).toHaveBeenCalled();
    });
  });

  describe("addParticipant", function() {
    it("add the participant", function() {
      expect(this.target.conversationParticipants).toEqual([]);
      this.target.addParticipant({name: "diaspora user", hande: "diaspora-user@pod.tld"});
      expect(this.target.conversationParticipants).toEqual([{name: "diaspora user", hande: "diaspora-user@pod.tld"}]);
    });

    it("does not creates duplicates", function() {
      this.target.conversationParticipants.push({name: "diaspora user", hande: "diaspora-user@pod.tld"});
      expect(this.target.conversationParticipants).toEqual([{name: "diaspora user", hande: "diaspora-user@pod.tld"}]);
      this.target.addParticipant({name: "diaspora user", hande: "diaspora-user@pod.tld"});
      expect(this.target.conversationParticipants).toEqual([{name: "diaspora user", hande: "diaspora-user@pod.tld"}]);
    });
  });

  describe("updateContactIdsListInput", function() {
    beforeEach(function() {
      this.target.conversationParticipants.push({id: 1, name: "diaspora user", handle: "diaspora-user@pod.tld"});
      this.target.conversationParticipants
        .push({id: 2, name: "other diaspora user", handle: "other-diaspora-user@pod.tld"});
      this.target.conversationParticipants.push({id: 3, name: "user@pod.tld", handle: "user@pod.tld"});
    });

    it("updates hidden input value", function() {
      this.target.updateContactIdsListInput();
      expect(this.target.getContactsIdsListInput().val()).toBe("1,2,3");
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

    it("calls $.fn.tags.addTag() for each participant", function() {
      spyOn(this.target.contactsTags, "addTag");
      this.target.updateContactIdsListInput();
      expect(this.target.contactsTags.addTag).toHaveBeenCalledTimes(3);
      expect(this.target.contactsTags.addTag.calls.argsFor(0)[0])
        .toEqual("diaspora user \u200B(diaspora-user@pod.tld)");
      expect(this.target.contactsTags.addTag.calls.argsFor(1)[0])
        .toEqual("other diaspora user \u200B(other-diaspora-user@pod.tld)");
      expect(this.target.contactsTags.addTag.calls.argsFor(2)[0])
        .toEqual("user@pod.tld");
    });
  });

  describe("bindTypeaheadEvents", function() {
    it("calls onSuggestionSelection() when clicking on a result", function() {
      spyOn(app.views.ConversationsForm.prototype, "onSuggestionSelection");
      var event = $.Event("typeahead:select");
      var person = {name: "diaspora user"};
      this.target.getTypeaheadElement().trigger(event, [person]);
      expect(app.views.ConversationsForm.prototype.onSuggestionSelection).toHaveBeenCalledWith(person);
    });
  });

  describe("onSuggestionSelection", function() {
    it("calls addParticipant(), updateContactIdsListInput() and $.fn.typeahead()", function() {
      spyOn(app.views.ConversationsForm.prototype, "addParticipant");
      spyOn(app.views.ConversationsForm.prototype, "updateContactIdsListInput");
      spyOn($.fn, "typeahead");
      var person = {name: "diaspora user"};
      this.target.onSuggestionSelection(person);
      expect(app.views.ConversationsForm.prototype.addParticipant).toHaveBeenCalledWith(person);
      expect(app.views.ConversationsForm.prototype.updateContactIdsListInput).toHaveBeenCalled();
      expect($.fn.typeahead).toHaveBeenCalledWith("val", "");
    });
  });

  describe("keyDown", function() {
    beforeEach(function() {
      this.submitCallback = jasmine.createSpy("submitSpy").and.returnValue(false);
      $(".new-conversation-btn").click();
    });

    context("new message", function() {
      beforeEach(function() {
        $(".new-conversation-btn").click();
        this.target.conversationParticipants.push({});
        $("form#new-conversation").submit(this.submitCallback);
      });

      it("should submit the form with ctrl+enter", function() {
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: true});
        $("textarea#new-message-text").trigger(e);
        expect(this.submitCallback).toHaveBeenCalled();
      });

      it("shouldn't submit the form without the ctrl key", function() {
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: false});
        $("textarea#new-message-text").trigger(e);
        expect(this.submitCallback).not.toHaveBeenCalled();
      });
    });

    context("response to an existing conversation", function() {
      beforeEach(function() {
        $("form#response-message").submit(this.submitCallback);
      });

      it("should submit the form with ctrl+enter", function() {
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: true});
        $("textarea#response-message-text").trigger(e);
        expect(this.submitCallback).toHaveBeenCalled();
      });

      it("shouldn't submit the form without the ctrl key", function() {
        var e = $.Event("keydown", {which: Keycodes.ENTER, ctrlKey: false});
        $("textarea#response-message-text").trigger(e);
        expect(this.submitCallback).not.toHaveBeenCalled();
      });
    });
  });

  describe("onSubmitForm", function() {
    beforeEach(function() {
      // Localisation
      /* eslint-disable camelcase */
      var locale = {conversation: {create: {no_contacts: "No contacts"}}};
      /* eslint-enable camelcase */
      Diaspora.I18n.load(locale, "en", locale);
    });

    it("cancel submission and warns the user if no contact was set", function() {
      var event = $.Event("click");
      spyOn(event, "stopPropagation");
      spyOn(app.flashMessages, "error");
      this.target.onSubmitForm(event);
      expect(event.stopPropagation).toHaveBeenCalled();
      expect(app.flashMessages.error).toHaveBeenCalledWith("No contacts");
    });
  });
});
