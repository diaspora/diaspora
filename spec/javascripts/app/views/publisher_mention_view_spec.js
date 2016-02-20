describe("app.views.PublisherMention", function(){
  beforeEach(function(){
    spec.content().html(
      "<div id='publisher'>" +
        "<textarea id='status_message_fake_text'></textarea>" +
      "</div>");
  });

  describe("initialize", function(){
    beforeEach(function(){
      spyOn(app.views.SearchBase.prototype, "initialize").and.callThrough();
      spyOn(app.views.PublisherMention.prototype, "bindMentioningEvents").and.callThrough();
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("initializes object properties", function(){
      expect(this.view.mentionsCollection).toEqual([]);
      expect(this.view.inputBuffer).toEqual([]);
      expect(this.view.currentDataQuery).toBe("");
      expect(this.view.mentionChar).toBe("\u200B");
    });

    it("calls completeSetup", function(){
      expect(app.views.SearchBase.prototype.initialize)
        .toHaveBeenCalledWith({typeaheadElement: this.view.getTypeaheadInput()});
      expect(app.views.PublisherMention.prototype.bindMentioningEvents).toHaveBeenCalled();
    });

    it("initializes html elements", function(){
      expect(this.view.$(".typeahead-mention-box").length).toBe(1);
      expect(this.view.$(".mentions-input-box").length).toBe(1);
      expect(this.view.$(".mentions-box").length).toBe(1);
      expect(this.view.$(".mentions").length).toBe(1);
    });
  });

  describe("bindMentioningEvents", function(){
    beforeEach(function(){
      spyOn(app.views.PublisherMention.prototype, "processMention");
      spyOn(app.views.PublisherMention.prototype, "resetMentionBox");
      spyOn(app.views.PublisherMention.prototype, "addToFilteredResults");
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.bloodhound.add([
        {"person": true, "name":"user1", "handle":"user1@pod.tld"},
        {"person": true, "name":"user2", "handle":"user2@pod.tld"}
      ]);
    });

    it("highlights the first item when rendering results", function(){
      this.view.getTypeaheadInput().typeahead("val", "user");
      this.view.getTypeaheadInput().typeahead("open");
      expect(this.view.$(".tt-suggestion").first()).toHaveClass("tt-cursor");
    });

    it("process mention when clicking a result", function(){
      this.view.getTypeaheadInput().typeahead("val", "user");
      this.view.getTypeaheadInput().typeahead("open");
      this.view.$(".tt-suggestion").first().click();
      expect(app.views.PublisherMention.prototype.processMention).toHaveBeenCalled();
      expect(app.views.PublisherMention.prototype.resetMentionBox).toHaveBeenCalled();
      expect(app.views.PublisherMention.prototype.addToFilteredResults).toHaveBeenCalled();
    });
  });

  describe("updateMentionsCollection", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("removes person from mention collection if not mentionned anymore", function(){
      this.view.mentionsCollection.push({name: "user1"});
      expect(this.view.mentionsCollection.length).toBe(1);
      this.view.updateMentionsCollection();
      expect(this.view.mentionsCollection.length).toBe(0);
    });

    it("removes item from mention collection if not a person", function(){
      this.view.mentionsCollection.push({});
      expect(this.view.mentionsCollection.length).toBe(1);
      this.view.updateMentionsCollection();
      expect(this.view.mentionsCollection.length).toBe(0);
    });
  });

  describe("addMention", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("add person to mentionned people", function(){
      expect(this.view.mentionsCollection.length).toBe(0);
      this.view.addMention({"name":"user1", "handle":"user1@pod.tld"});
      expect(this.view.mentionsCollection.length).toBe(1);
      expect(this.view.mentionsCollection[0]).toEqual({
        /* jshint camelcase: false */
        "name":"user1", "handle":"user1@pod.tld", diaspora_id: "user1@pod.tld"});
        /* jshint camelcase: true */
    });

    it("does not add mention if not a person", function(){
      expect(this.view.mentionsCollection.length).toBe(0);
      this.view.addMention();
      expect(this.view.mentionsCollection.length).toBe(0);
      this.view.addMention({});
      expect(this.view.mentionsCollection.length).toBe(0);
      this.view.addMention({"name": "user1"});
      expect(this.view.mentionsCollection.length).toBe(0);
      this.view.addMention({"handle":"user1@pod.tld"});
      expect(this.view.mentionsCollection.length).toBe(0);
    });
  });

  describe("getTypeaheadInput", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("inserts typeahead input if it does not already exist", function(){
      this.view.getTypeaheadInput().remove();
      expect(this.view.$(".typeahead-mention-box").length).toBe(0);
      this.view.getTypeaheadInput();
      expect(this.view.$(".typeahead-mention-box").length).toBe(1);
    });
  });

  describe("processMention", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.elmInputBox.val("@user1 Text before @user1 text after");
      this.view.currentDataQuery = "user1";
      this.view.elmInputBox[0].setSelectionRange(25, 25);
    });

    it("add person to mentionned people", function(){
      spyOn(this.view, "addMention");
      this.view.processMention({"name":"user1", "handle":"user1@pod.tld"});
      expect(this.view.addMention).toHaveBeenCalledWith({"name":"user1", "handle":"user1@pod.tld"});
    });

    it("cleans buffers", function(){
      spyOn(this.view, "clearBuffer");
      spyOn(this.view, "resetMentionBox");
      this.view.processMention({"name":"user1", "handle":"user1@pod.tld"});
      expect(this.view.clearBuffer).toHaveBeenCalled();
      expect(this.view.resetMentionBox).toHaveBeenCalled();
      expect(this.view.currentDataQuery).toBe("");
    });

    it("correctly formats the text", function(){
      spyOn(this.view, "updateValues");
      this.view.processMention({"name":"user1", "handle":"user1@pod.tld"});
      expect(this.view.updateValues).toHaveBeenCalled();
      expect(this.view.getInputBoxValue()).toBe("@user1 Text before " + this.view.mentionChar + "user1 text after");
    });

    it("places the caret at the right position", function(){
      this.view.processMention({"name":"user1WithLongName", "handle":"user1@pod.tld"});
      var expectedCaretPosition = ("@user1 Text before " + this.view.mentionChar + "user1WithLongName").length;
      expect(this.view.elmInputBox[0].selectionStart).toBe(expectedCaretPosition);
    });
  });

  describe("updateValues", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.elmInputBox.val("@user1 Text before " + this.view.mentionChar + "user1\ntext after");
      this.view.mentionsCollection.push({"name":"user1", "handle":"user1@pod.tld"});
    });

    it("filters mention from future results", function(){
      spyOn(this.view, "clearFilteredResults");
      spyOn(this.view, "addToFilteredResults");
      this.view.updateValues();
      expect(this.view.clearFilteredResults).toHaveBeenCalled();
      expect(this.view.addToFilteredResults).toHaveBeenCalledWith({"name":"user1", "handle":"user1@pod.tld"});
    });

    it("formats message text data with correct mentionning syntax", function(){
      this.view.updateValues();
      expect(this.view.elmInputBox.data("messageText")).toBe("@user1 Text before @{user1 ; user1@pod.tld}\ntext after");
    });

    it("formats overlay text to HTML", function(){
      this.view.updateValues();
      expect(this.view.elmMentionsOverlay.find("div > div").html())
        .toBe("@user1 Text before <strong><span>user1</span></strong><br>text after");
    });
  });

  describe("prefillMention", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      spyOn(this.view, "addMention");
      spyOn(this.view, "addToFilteredResults");
      spyOn(this.view, "updateValues");
    });

    it("prefills one mention", function(){
      this.view.prefillMention([{"name":"user1", "handle":"user1@pod.tld"}]);

      expect(this.view.addMention).toHaveBeenCalledWith({"name":"user1", "handle":"user1@pod.tld"});
      expect(this.view.addToFilteredResults)
        .toHaveBeenCalledWith({"name":"user1", "handle":"user1@pod.tld"});
      expect(this.view.updateValues).toHaveBeenCalled();
      expect(this.view.getInputBoxValue()).toBe(this.view.mentionChar + "user1");
    });

    it("prefills multiple mentions", function(){
      this.view.prefillMention([
        {"name":"user1", "handle":"user1@pod.tld"},
        {"name":"user2", "handle":"user2@pod.tld"}
      ]);

      expect(this.view.addMention).toHaveBeenCalledWith({"name":"user1", "handle":"user1@pod.tld"});
      expect(this.view.addMention).toHaveBeenCalledWith({"name":"user2", "handle":"user2@pod.tld"});
      expect(this.view.addToFilteredResults).toHaveBeenCalledWith({"name":"user1", "handle":"user1@pod.tld"});
      expect(this.view.addToFilteredResults).toHaveBeenCalledWith({"name":"user2", "handle":"user2@pod.tld"});
      expect(this.view.updateValues).toHaveBeenCalled();
      expect(this.view.getInputBoxValue()).toBe(this.view.mentionChar + "user1 " + this.view.mentionChar + "user2");
    });
  });

  describe("onInputBoxPaste", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("add person to mentionned people", function(){
      var pasteEvent = {originalEvent: {clipboardData: {getData: function(){
        return "Pasted text";
      }}}};

      this.view.onInputBoxPaste(pasteEvent);
      expect(this.view.inputBuffer).toEqual(["P", "a", "s", "t", "e", "d", " ", "t", "e", "x", "t"]);
    });
  });

  describe("reset", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      spyOn(this.view, "clearFilteredResults");
      spyOn(this.view, "updateValues");
    });

    it("resets the mention box", function(){
      this.view.reset();
      expect(this.view.elmInputBox.val()).toBe("");
      expect(this.view.mentionsCollection.length).toBe(0);
      expect(this.view.clearFilteredResults).toHaveBeenCalled();
      expect(this.view.updateValues).toHaveBeenCalled();
    });
  });

  describe("showMentionBox", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.bloodhound.add([
        {"person": true, "name":"user1", "handle":"user1@pod.tld"}
      ]);
      this.view.currentDataQuery = "user1";
    });

    it("shows the mention box", function(){
      expect(this.view.$(".tt-menu").is(":visible")).toBe(false);
      expect(this.view.$(".tt-menu .tt-suggestion").length).toBe(0);
      this.view.showMentionBox();
      expect(this.view.$(".tt-menu").is(":visible")).toBe(true);
      expect(this.view.$(".tt-menu .tt-suggestion").length).toBe(1);
    });
  });

  describe("resetMentionBox", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.bloodhound.add([
        {"person": true, "name":"user1", "handle":"user1@pod.tld"}
      ]);
    });

    it("resets results and closes mention box", function(){
      this.view.getTypeaheadInput().typeahead("val", "user");
      this.view.getTypeaheadInput().typeahead("open");
      expect(this.view.$(".tt-menu").is(":visible")).toBe(true);
      expect(this.view.$(".tt-menu .tt-suggestion").length >= 1).toBe(true);
      this.view.resetMentionBox();
      expect(this.view.$(".tt-menu").is(":visible")).toBe(false);
      expect(this.view.$(".tt-menu .tt-suggestion").length).toBe(0);
    });
  });

  describe("getInputBoxValue", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
    });

    it("returns trimmed text", function(){
      this.view.elmInputBox.val("Text with trailing spaces        ");
      expect(this.view.getInputBoxValue()).toBe("Text with trailing spaces");
    });
  });

  describe("getTextForSubmit", function(){
    beforeEach(function(){
      this.view = new app.views.PublisherMention({ el: "#publisher" });
      this.view.bloodhound.add([
        {"person": true, "name":"user1", "handle":"user1@pod.tld"}
      ]);
    });

    it("returns text with mention syntax if someone is mentionned", function(){
      this.view.getTypeaheadInput().typeahead("val", "user");
      this.view.getTypeaheadInput().typeahead("open");
      this.view.$(".tt-suggestion").first().click();
      expect(this.view.getTextForSubmit()).toBe("@{user1 ; user1@pod.tld}");
    });

    it("returns normal text if nobody is mentionned", function(){
      this.view.elmInputBox.data("messageText", "Bad text");
      this.view.elmInputBox.val("Good text");
      expect(this.view.getTextForSubmit()).toBe("Good text");
    });
  });
});
