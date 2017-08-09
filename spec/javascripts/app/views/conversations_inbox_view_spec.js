describe("app.views.ConversationsInbox", function() {
  describe("initialize", function() {
    beforeEach(function() {
      spec.loadFixture("conversations_read");
      $("#conversation-new").removeClass("hidden");
      $("#conversation-show").addClass("hidden");
    });

    it("initializes the conversations form", function() {
      spyOn(app.views.ConversationsForm.prototype, "initialize");
      new app.views.ConversationsInbox();
      expect(app.views.ConversationsForm.prototype.initialize).toHaveBeenCalled();
    });

    it("calls setupConversation", function() {
      spyOn(app.views.ConversationsInbox.prototype, "setupConversation");
      new app.views.ConversationsInbox();
      expect(app.views.ConversationsInbox.prototype.setupConversation).toHaveBeenCalled();
    });

    it("creates markdown editor for an existing conversation", function() {
      spyOn(app.views.ConversationsForm.prototype, "renderMarkdownEditor");
      new app.views.ConversationsInbox(1);
      expect(app.views.ConversationsForm.prototype.renderMarkdownEditor).toHaveBeenCalledWith(
        "#conversation-show .conversation-message-text"
      );
    });
  });

  describe("renderConversation", function() {
    beforeEach(function() {
      spec.loadFixture("conversations_read");
      $("#conversation-new").removeClass("hidden");
      $("#conversation-show").addClass("hidden");
      var conversations = $("#conversation-inbox .stream-element");
      conversations.removeClass("selected");
      this.conversationId = conversations.first().data("guid");
      this.target = new app.views.ConversationsInbox();
    });

    it("renders conversation of given id", function() {
      spyOn($, "ajax").and.callThrough();
      spyOn(app.views.ConversationsInbox.prototype, "selectConversation");
      spyOn(app.views.ConversationsInbox.prototype, "setupConversation");
      spyOn(app.views.ConversationsForm.prototype, "renderMarkdownEditor");
      spyOn(window, "autosize");
      this.target.renderConversation(this.conversationId);
      jasmine.Ajax.requests.mostRecent().respondWith({
        status: 200,
        responseText: "<div id='fake-conversation-content'></div>"
      });

      expect($.ajax).toHaveBeenCalled();
      expect(jasmine.Ajax.requests.mostRecent().url).toBe("/conversations/" + this.conversationId + "/raw");
      expect(app.views.ConversationsInbox.prototype.selectConversation).toHaveBeenCalledWith(this.conversationId);
      expect(app.views.ConversationsInbox.prototype.setupConversation).toHaveBeenCalled();
      expect(app.views.ConversationsForm.prototype.renderMarkdownEditor).toHaveBeenCalled();
      expect(window.autosize).toHaveBeenCalled();
      expect(window.autosize.calls.mostRecent().args[0].is($("#conversation-show textarea")));
      expect($("#conversation-new")).toHaveClass("hidden");
      expect($("#conversation-show")).not.toHaveClass("hidden");
      expect($("#conversation-show #fake-conversation-content").length).toBe(1);
    });
  });

  describe("selectConversation", function() {
    beforeEach(function() {
      spec.loadFixture("conversations_read");
      this.conversationId = $("#conversation-inbox .stream-element").first().data("guid");
      this.target = new app.views.ConversationsInbox();
      $("#conversation-inbox .stream-element").addClass("selected");
    });

    it("unselects every conversation if called with no parameters", function() {
      expect($("#conversation-inbox .stream-element.selected").length).not.toBe(0);
      this.target.selectConversation();
      expect($("#conversation-inbox .stream-element.selected").length).toBe(0);
    });

    it("selects the given conversation", function() {
      expect($("#conversation-inbox .stream-element.selected").length).not.toBe(1);
      this.target.selectConversation(this.conversationId);
      expect($("#conversation-inbox .stream-element.selected").length).toBe(1);
      expect($("#conversation-inbox .stream-element.selected").data("guid")).toBe(this.conversationId);
    });
  });

  describe("displayNewConversation", function() {
    beforeEach(function() {
      spec.loadFixture("conversations_read");
      $("#conversation-new").addClass("hidden");
      $("#conversation-show").removeClass("hidden");
      spyOn(app.views.ConversationsInbox.prototype, "selectConversation");
      new app.views.ConversationsInbox();
    });

    it("displays the new conversation panel", function() {
      $(".new-conversation-btn").click();

      expect(app.views.ConversationsInbox.prototype.selectConversation).toHaveBeenCalledWith();
      expect($("#conversation-new")).not.toHaveClass("hidden");
      expect($("#conversation-show")).toHaveClass("hidden");
      expect(window.location.pathname).toBe("/conversations");
    });
  });

  describe("setupConversation", function() {
    context("for unread conversations", function() {
      beforeEach(function() {
        spec.loadFixture("conversations_unread");
        // select second conversation that is still unread
        $(".conversation-wrapper > .conversation.selected").removeClass("selected");
        $(".conversation-wrapper > .conversation.unread").addClass("selected");
      });

      it("calls setupAvatarFallback", function() {
        this.view = new app.views.ConversationsInbox();
        spyOn(this.view, "setupAvatarFallback");
        this.view.setupConversation();
        expect(this.view.setupAvatarFallback).toHaveBeenCalled();
      });

      it("removes the unread class from the conversation", function() {
        expect($(".conversation-wrapper > .conversation.selected")).toHaveClass("unread");
        new app.views.ConversationsInbox();
        expect($(".conversation-wrapper > .conversation.selected")).not.toHaveClass("unread");
      });

      it("removes the unread message counter from the conversation", function() {
        expect($(".conversation-wrapper > .conversation.selected .unread-message-count").length).toEqual(1);
        new app.views.ConversationsInbox();
        expect($(".conversation-wrapper > .conversation.selected .unread-message-count").length).toEqual(0);
      });

      it("decreases the unread message count in the header", function() {
        var badge = "<div id=\"conversations-link\"><div class=\"badge\">3</div></div>";
        $("header").append(badge);
        expect($("#conversations-link .badge").text().trim()).toEqual("3");
        expect($(".conversation-wrapper > .conversation .unread-message-count").text().trim()).toEqual("1");
        new app.views.ConversationsInbox();
        expect($("#conversations-link .badge").text().trim()).toEqual("2");
      });

      it("removes the badge in the header if there are no unread messages left", function() {
        var badge = "<div id=\"conversations-link\"><div class=\"badge\">1</div></div>";
        $("header").append(badge);
        expect($("#conversations-link .badge").text().trim()).toEqual("1");
        expect($(".conversation-wrapper > .conversation.selected .unread-message-count").text().trim()).toEqual("1");
        new app.views.ConversationsInbox();
        expect($("#conversations-link .badge").text().trim()).toEqual("0");
        expect($("#conversations-link .badge")).toHaveClass("hidden");
      });
    });

    context("for read conversations", function() {
      beforeEach(function() {
        spec.loadFixture("conversations_read");
      });

      it("does not change the badge in the header", function() {
        var badge = "<div id=\"conversations-link\"><div class=\"badge\">3</div></div>";
        $("header").append(badge);
        expect($("#conversations-link .badge").text().trim()).toEqual("3");
        new app.views.ConversationsInbox();
        expect($("#conversations-link .badge").text().trim()).toEqual("3");
      });
    });
  });

  describe("displayConversation", function() {
    beforeEach(function() {
      spyOn(app.router, "navigate");
      spec.loadFixture("conversations_read");
      new app.views.ConversationsInbox();
    });

    it("calls app.router.navigate with correct parameters", function() {
      var conversationEl = $(".conversation-wrapper").first();
      var conversationPath = conversationEl.data("conversation-path");
      conversationEl.children().first().click();
      expect(app.router.navigate).toHaveBeenCalledWith(conversationPath, {trigger: true});
    });
  });
});
