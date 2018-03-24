describe("app.views.PublisherMention", function() {
  beforeEach(function() {
    spec.loadFixture("aspects_index");
  });

  describe("initialize", function() {
    it("initializes object properties", function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      expect(this.view.mentionedPeople).toEqual([]);
      expect(this.view.triggerChar).toBe("@");
    });

    it("calls app.views.SearchBase.initialize", function() {
      spyOn(app.views.SearchBase.prototype, "initialize");
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      expect(app.views.SearchBase.prototype.initialize).toHaveBeenCalled();
      var call = app.views.SearchBase.prototype.initialize.calls.mostRecent();
      expect(call.args[0].typeaheadInput.is($("#publisher .typeahead-mention-box"))).toBe(true);
      expect(call.args[0].customSearch).toBeTruthy();
      expect(call.args[0].autoselect).toBeTruthy();
      expect(call.args[0].remoteRoute).toEqual({url: "/contacts"});
    });

    it("calls bindTypeaheadEvents", function() {
      spyOn(app.views.PublisherMention.prototype, "bindTypeaheadEvents");
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      expect(app.views.PublisherMention.prototype.bindTypeaheadEvents).toHaveBeenCalled();
    });
  });

  describe("mentionSyntaxTemplate", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({el: "#publisher"});
      this.person = {handle: "alice@pod.tld", name: "Alice Awesome"};
    });

    it("returns the correct mention syntax", function() {
      expect(this.view.mentionSyntaxTemplate(this.person)).toBe("@{alice@pod.tld}");
    });
  });

  describe("bindTypeaheadEvents", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.bloodhound.add([
        {person: true, name: "user1", handle: "user1@pod.tld"},
        {person: true, name: "user2", handle: "user2@pod.tld"}
      ]);
    });

    it("process mention when clicking a result", function() {
      spyOn(this.view, "onSuggestionSelection");
      this.view.typeaheadInput.typeahead("val", "user");
      this.view.typeaheadInput.typeahead("open");
      $(".tt-suggestion").first().click();
      expect(this.view.onSuggestionSelection).toHaveBeenCalledWith(
        {person: true, name: "user1", handle: "user1@pod.tld"}
      );
    });
  });

  describe("addPersonToMentions", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("adds a person to mentioned people", function() {
      expect(this.view.mentionedPeople.length).toBe(0);
      this.view.addPersonToMentions({name: "user1", handle: "user1@pod.tld"});
      expect(this.view.mentionedPeople.length).toBe(1);
      expect(this.view.mentionedPeople[0]).toEqual({
        /* jshint camelcase: false */
        name: "user1", handle: "user1@pod.tld", diaspora_id: "user1@pod.tld"});
        /* jshint camelcase: true */
    });

    it("adds a person to the ignored diaspora ids", function() {
      spyOn(this.view, "ignorePersonForSuggestions");
      this.view.addPersonToMentions({name: "user1", handle: "user1@pod.tld"});
      expect(this.view.ignorePersonForSuggestions).toHaveBeenCalledWith({
        /* jshint camelcase: false */
        name: "user1", handle: "user1@pod.tld", diaspora_id: "user1@pod.tld"});
        /* jshint camelcase: true */
    });

    it("doesn't add mention if not a person", function() {
      expect(this.view.mentionedPeople.length).toBe(0);
      this.view.addPersonToMentions();
      expect(this.view.mentionedPeople.length).toBe(0);
      this.view.addPersonToMentions({});
      expect(this.view.mentionedPeople.length).toBe(0);
      this.view.addPersonToMentions({name: "user1"});
      expect(this.view.mentionedPeople.length).toBe(0);
      this.view.addPersonToMentions({handle: "user1@pod.tld"});
      expect(this.view.mentionedPeople.length).toBe(0);
    });
  });

  describe("cleanMentionedPeople", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("removes person from mentioned people if not mentioned anymore", function() {
      this.view.addPersonToMentions({name: "User Name", handle: "user1@pod.tld"});
      expect(this.view.mentionedPeople.length).toBe(1);
      this.view.cleanMentionedPeople();
      expect(this.view.mentionedPeople.length).toBe(0);
    });

    it("removes person from ignored people if not mentioned anymore", function() {
      this.view.addPersonToMentions({name: "User Name", handle: "user1@pod.tld"});
      expect(this.view.ignoreDiasporaIds.length).toBe(1);
      this.view.cleanMentionedPeople();
      expect(this.view.ignoreDiasporaIds.length).toBe(0);
    });

    it("keeps mentioned persons", function() {
      this.view.addPersonToMentions({name: "User Name", handle: "user1@pod.tld"});
      this.view.inputBox.val("@{user1@pod.tld}");
      expect(this.view.mentionedPeople.length).toBe(1);
      this.view.cleanMentionedPeople();
      expect(this.view.mentionedPeople.length).toBe(1);
    });

    it("keeps mentioned persons for ignored diaspora ids", function() {
      this.view.addPersonToMentions({name: "User Name", handle: "user1@pod.tld"});
      this.view.inputBox.val("@{user1@pod.tld}");
      expect(this.view.ignoreDiasporaIds.length).toBe(1);
      this.view.cleanMentionedPeople();
      expect(this.view.ignoreDiasporaIds.length).toBe(1);
    });
  });

  describe("onSuggestionSelection", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.inputBox.val("@user1337 Text before @user1 text after");
      this.view.inputBox[0].setSelectionRange(28, 28);
    });

    it("doesn't do anything if there is no '@' in front of the caret", function() {
      spyOn(this.view, "addPersonToMentions");
      this.view.inputBox.val("user1337 Text before @user1 text after");
      this.view.inputBox[0].setSelectionRange(9, 9);
      this.view.onSuggestionSelection({name: "user1337", handle: "user1@pod.tld"});
      expect(this.view.addPersonToMentions).not.toHaveBeenCalled();
    });

    it("adds a person to mentioned people", function() {
      spyOn(this.view, "addPersonToMentions");
      this.view.onSuggestionSelection({name: "user1337", handle: "user1@pod.tld"});
      expect(this.view.addPersonToMentions).toHaveBeenCalledWith({name: "user1337", handle: "user1@pod.tld"});
    });

    it("closes the suggestions box", function() {
      spyOn(this.view, "closeSuggestions");
      this.view.onSuggestionSelection({name: "user1337", handle: "user1@pod.tld"});
      expect(this.view.closeSuggestions).toHaveBeenCalled();
    });

    it("correctly formats the text", function() {
      this.view.onSuggestionSelection({name: "user1337", handle: "user1@pod.tld"});
      expect(this.view.inputBox.val()).toBe("@user1337 Text before @{user1@pod.tld} text after");
    });

    it("replaces the correct mention", function() {
      this.view.inputBox.val("@user1337 123 user2 @user2 456 @user3 789");
      this.view.inputBox[0].setSelectionRange(26, 26);
      this.view.onSuggestionSelection({name: "user23", handle: "user2@pod.tld"});
      expect(this.view.inputBox.val()).toBe("@user1337 123 user2 @{user2@pod.tld} 456 @user3 789");
      this.view.inputBox[0].setSelectionRange(9, 9);
      this.view.onSuggestionSelection({name: "user1337", handle: "user1@pod.tld"});
      expect(this.view.inputBox.val()).toBe("@{user1@pod.tld} 123 user2 @{user2@pod.tld} 456 @user3 789");
      this.view.inputBox[0].setSelectionRange(54, 54);
      this.view.onSuggestionSelection({name: "user32", handle: "user3@pod.tld"});
      expect(this.view.inputBox.val()).toBe("@{user1@pod.tld} 123 user2 @{user2@pod.tld} 456 @{user3@pod.tld} 789");
    });

    it("places the caret at the right position", function() {
      this.view.onSuggestionSelection({"name": "user1WithLongName", "handle": "user1@pod.tld"});
      var expectedCaretPosition = ("@user1337 Text before @{user1@pod.tld}").length;
      expect(this.view.inputBox[0].selectionStart).toBe(expectedCaretPosition);
    });
  });

  describe("updateTypeaheadInput", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.inputBox.val("@user1337 Text before @user1 text after");
      this.view.inputBox[0].setSelectionRange(28, 28);
    });

    it("calls 'closeSuggestions' if there is no '@' in front of the caret", function() {
      spyOn(this.view, "closeSuggestions");
      this.view.inputBox.val("user1337 Text before @user1 text after");
      this.view.inputBox[0].setSelectionRange(9, 9);
      this.view.updateTypeaheadInput();
      expect(this.view.closeSuggestions).toHaveBeenCalled();
    });

    it("calls 'closeSuggestions' if there is a whitespace between the '@' and the caret", function() {
      spyOn(this.view, "closeSuggestions");
      this.view.inputBox.val("@user1337 Text before @user1 text after");
      this.view.inputBox[0].setSelectionRange(9, 9);
      this.view.updateTypeaheadInput();
      expect(this.view.closeSuggestions.calls.count()).toEqual(0);
      this.view.inputBox[0].setSelectionRange(10, 10);
      this.view.updateTypeaheadInput();
      expect(this.view.closeSuggestions.calls.count()).toEqual(1);
      this.view.inputBox[0].setSelectionRange(11, 11);
      this.view.updateTypeaheadInput();
      expect(this.view.closeSuggestions.calls.count()).toEqual(2);
    });

    it("fills the typeahead input with the correct text", function() {
      spyOn(this.view, "closeSuggestions");
      this.view.inputBox.val("@user1337 Text before @user1 text after");
      this.view.inputBox[0].setSelectionRange(2, 2);
      this.view.updateTypeaheadInput();
      expect(this.view.closeSuggestions).not.toHaveBeenCalled();
      expect(this.view.typeaheadInput.val()).toBe("u");
      this.view.inputBox[0].setSelectionRange(9, 9);
      this.view.updateTypeaheadInput();
      expect(this.view.closeSuggestions).not.toHaveBeenCalled();
      expect(this.view.typeaheadInput.val()).toBe("user1337");
      this.view.inputBox[0].setSelectionRange(27, 27);
      this.view.updateTypeaheadInput();
      expect(this.view.closeSuggestions).not.toHaveBeenCalled();
      expect(this.view.typeaheadInput.val()).toBe("user");
    });

    it("doesn't call 'cleanMentionedPeople' if there is no '@' in front of the caret", function() {
      spyOn(this.view, "cleanMentionedPeople");
      this.view.inputBox.val("user1337 Text before @user1 text after");
      this.view.inputBox[0].setSelectionRange(9, 9);
      this.view.updateTypeaheadInput();
      expect(this.view.cleanMentionedPeople).not.toHaveBeenCalled();
    });

    it("calls 'cleanMentionedPeople' if there is an '@' in front of the caret", function() {
      spyOn(this.view, "cleanMentionedPeople");
      this.view.inputBox.val("@user1337 Text before @user1 text after");
      this.view.inputBox[0].setSelectionRange(9, 9);
      this.view.updateTypeaheadInput();
      expect(this.view.cleanMentionedPeople).toHaveBeenCalled();
    });
  });

  describe("prefillMention", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      spyOn(this.view, "addPersonToMentions");
    });

    it("prefills one mention", function() {
      this.view.prefillMention([{"name": "user1", "handle": "user1@pod.tld"}]);
      expect(this.view.addPersonToMentions).toHaveBeenCalledWith({"name": "user1", "handle": "user1@pod.tld"});
      expect(this.view.inputBox.val()).toBe("@{user1@pod.tld}");
    });

    it("prefills multiple mentions", function() {
      this.view.prefillMention([
        {"name": "user1", "handle": "user1@pod.tld"},
        {"name": "user2", "handle": "user2@pod.tld"}
      ]);

      expect(this.view.addPersonToMentions).toHaveBeenCalledWith({"name": "user1", "handle": "user1@pod.tld"});
      expect(this.view.addPersonToMentions).toHaveBeenCalledWith({"name": "user2", "handle": "user2@pod.tld"});
      expect(this.view.inputBox.val()).toBe("@{user1@pod.tld} @{user2@pod.tld}");
    });
  });

  describe("onInputBoxKeyDown", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    context("escape key", function() {
      beforeEach(function() {
        this.evt = $.Event("keydown", {which: Keycodes.ESC});
      });

      it("calls 'closeSuggestions'", function() {
        spyOn(this.view, "closeSuggestions");
        this.view.onInputBoxKeyDown(this.evt);
        expect(this.view.closeSuggestions).toHaveBeenCalled();
      });
    });

    context("space key", function() {
      beforeEach(function() {
        this.evt = $.Event("keydown", {which: Keycodes.SPACE});
      });

      it("calls 'closeSuggestions'", function() {
        spyOn(this.view, "closeSuggestions");
        this.view.onInputBoxKeyDown(this.evt);
        expect(this.view.closeSuggestions).toHaveBeenCalled();
      });
    });

    context("up key", function() {
      beforeEach(function() {
        this.evt = $.Event("keydown", {which: Keycodes.UP});
      });

      it("calls 'onArrowKeyDown'", function() {
        spyOn(this.view, "onArrowKeyDown");
        this.view.onInputBoxKeyDown(this.evt);
        expect(this.view.onArrowKeyDown).toHaveBeenCalled();
      });
    });

    context("down key", function() {
      beforeEach(function() {
        this.evt = $.Event("keydown", {which: Keycodes.DOWN});
      });

      it("calls 'onArrowKeyDown'", function() {
        spyOn(this.view, "onArrowKeyDown");
        this.view.onInputBoxKeyDown(this.evt);
        expect(this.view.onArrowKeyDown).toHaveBeenCalled();
      });
    });

    context("return key", function() {
      beforeEach(function() {
        this.evt = $.Event("keydown", {which: Keycodes.RETURN});
        this.view.bloodhound.add([
          {person: true, name: "user1", handle: "user1@pod.tld"},
          {person: true, name: "user2", handle: "user2@pod.tld"}
        ]);
        this.view.typeaheadInput.typeahead("val", "user");
        this.view.typeaheadInput.typeahead("open");
        $(".tt-suggestion").first().addClass(".tt-cursor");
      });

      it("calls 'onSuggestionSelection'", function() {
        spyOn(this.view, "onSuggestionSelection");
        this.view.onInputBoxKeyDown(this.evt);
        expect(this.view.onSuggestionSelection).toHaveBeenCalled();
      });
    });

    context("tab key", function() {
      beforeEach(function() {
        this.evt = $.Event("keydown", {which: Keycodes.TAB});
        this.view.bloodhound.add([
          {person: true, name: "user1", handle: "user1@pod.tld"},
          {person: true, name: "user2", handle: "user2@pod.tld"}
        ]);
        this.view.typeaheadInput.typeahead("val", "user");
        this.view.typeaheadInput.typeahead("open");
        $(".tt-suggestion").first().addClass(".tt-cursor");
      });

      it("calls 'onSuggestionSelection'", function() {
        spyOn(this.view, "onSuggestionSelection");
        this.view.onInputBoxKeyDown(this.evt);
        expect(this.view.onSuggestionSelection).toHaveBeenCalled();
      });
    });
  });

  describe("onInputBoxClick", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("calls 'updateTypeaheadInput'", function() {
      spyOn(this.view, "updateTypeaheadInput");
      this.view.onInputBoxClick();
      expect(this.view.updateTypeaheadInput).toHaveBeenCalled();
    });
  });

  describe("onInputBoxBlur", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("calls 'closeSuggestions'", function() {
      spyOn(this.view, "closeSuggestions");
      this.view.onInputBoxBlur();
      expect(this.view.closeSuggestions).toHaveBeenCalled();
    });
  });

  describe("reset", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      spyOn(this.view, "updateTypeaheadInput");
    });

    it("resets the mention box", function() {
      this.view.reset();
      expect(this.view.inputBox.val()).toBe("");
      expect(this.view.updateTypeaheadInput).toHaveBeenCalled();
    });
  });

  describe("closeSuggestions", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.bloodhound.add([
        {"person": true, "name": "user1", "handle": "user1@pod.tld"}
      ]);
    });

    it("resets results and closes mention box", function() {
      this.view.typeaheadInput.typeahead("val", "user");
      this.view.typeaheadInput.typeahead("open");
      expect(this.view.$(".tt-menu").is(":visible")).toBe(true);
      expect(this.view.$(".tt-menu .tt-suggestion").length).toBeGreaterThan(0);
      expect(this.view.typeaheadInput.val()).toBe("user");
      this.view.closeSuggestions();
      expect(this.view.$(".tt-menu").is(":visible")).toBe(false);
      expect(this.view.$(".tt-menu .tt-suggestion").length).toBe(0);
      expect(this.view.typeaheadInput.val()).toBe("");
    });
  });

  describe("getMentionedPeople", function() {
    beforeEach(function() {
      this.view = new app.views.PublisherMention({el: "#publisher"});
    });

    it("calls 'cleanMentionedPeople'", function() {
      spyOn(this.view, "cleanMentionedPeople");
      this.view.getMentionedPeople();
      expect(this.view.cleanMentionedPeople).toHaveBeenCalled();
    });

    it("returns the cleaned mentionedPeople", function() {
      this.view.inputBox.val("@{user1@pod.tld} user2@pod.tld");
      this.view.mentionedPeople = [{name: "user1", handle: "user1@pod.tld"}, {name: "user2", handle: "user2@pod.tld"}];
      expect(this.view.getMentionedPeople()).toEqual([{name: "user1", handle: "user1@pod.tld"}]);
    });
  });
});
