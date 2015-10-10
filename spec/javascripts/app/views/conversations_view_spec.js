describe("app.views.Conversations", function(){
  describe("setupConversation", function() {
    context("for unread conversations", function() {
      beforeEach(function() {
        spec.loadFixture("conversations_unread");
        // select second conversation that is still unread
        $(".conversation-wrapper > .conversation.selected").removeClass("selected");
        $(".conversation-wrapper > .conversation.unread").addClass("selected");
      });

      it("removes the unread class from the conversation", function() {
        expect($(".conversation-wrapper > .conversation.selected")).toHaveClass("unread");
        new app.views.Conversations();
        expect($(".conversation-wrapper > .conversation.selected")).not.toHaveClass("unread");
      });

      it("removes the unread message counter from the conversation", function() {
        expect($(".conversation-wrapper > .conversation.selected .unread-message-count").length).toEqual(1);
        new app.views.Conversations();
        expect($(".conversation-wrapper > .conversation.selected .unread-message-count").length).toEqual(0);
      });

      it("decreases the unread message count in the header", function() {
        var badge = "<div id=\"conversations-link\"><div class=\"badge\">3</div></div>";
        $("header").append(badge);
        expect($("#conversations-link .badge").text().trim()).toEqual("3");
        expect($(".conversation-wrapper > .conversation .unread-message-count").text().trim()).toEqual("1");
        new app.views.Conversations();
        expect($("#conversations-link .badge").text().trim()).toEqual("2");
      });

      it("removes the badge in the header if there are no unread messages left", function() {
        var badge = "<div id=\"conversations-link\"><div class=\"badge\">1</div></div>";
        $("header").append(badge);
        expect($("#conversations-link .badge").text().trim()).toEqual("1");
        expect($(".conversation-wrapper > .conversation.selected .unread-message-count").text().trim()).toEqual("1");
        new app.views.Conversations();
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
        new app.views.Conversations();
        expect($("#conversations-link .badge").text().trim()).toEqual("3");
      });
    });
  });

  describe("keyDown", function(){
    beforeEach(function() {
      this.submitCallback = jasmine.createSpy().and.returnValue(false);
      spec.loadFixture("conversations_read");
      new app.views.Conversations();
    });

    it("should submit the form with ctrl+enter", function(){
      $("form#new_message").submit(this.submitCallback);
      var e = $.Event("keydown", { keyCode: 13, ctrlKey: true });
      $("textarea#message_text").trigger(e);
      expect(this.submitCallback).toHaveBeenCalled();
    });

    it("shouldn't submit the form without the ctrl key", function(){
      $("form#new_message").submit(this.submitCallback);
      var e = $.Event("keydown", { keyCode: 13, ctrlKey: false });
      $("textarea#message_text").trigger(e);
      expect(this.submitCallback).not.toHaveBeenCalled();
    });
  });
});
