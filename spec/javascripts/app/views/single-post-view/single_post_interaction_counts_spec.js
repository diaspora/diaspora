describe("app.views.SinglePostInteractionCounts", function() {
  beforeEach(function() {
    this.post = factory.postWithInteractions();
    this.view = new app.views.SinglePostInteractionCounts({model: this.post});
  });

  describe("initialize", function() {
    it("calls render when the interactions change", function() {
      spyOn(app.views.SinglePostInteractionCounts.prototype, "render");
      this.view.initialize();
      expect(app.views.SinglePostInteractionCounts.prototype.render).not.toHaveBeenCalled();
      this.post.interactions.trigger("change");
      expect(app.views.SinglePostInteractionCounts.prototype.render).toHaveBeenCalled();
    });

    it("calls render when the likes change", function() {
      spyOn(app.views.SinglePostInteractionCounts.prototype, "render");
      this.view.initialize();
      expect(app.views.SinglePostInteractionCounts.prototype.render).not.toHaveBeenCalled();
      this.post.interactions.likes.trigger("change");
      expect(app.views.SinglePostInteractionCounts.prototype.render).toHaveBeenCalled();
    });

    it("calls render when the reshares change", function() {
      spyOn(app.views.SinglePostInteractionCounts.prototype, "render");
      this.view.initialize();
      expect(app.views.SinglePostInteractionCounts.prototype.render).not.toHaveBeenCalled();
      this.post.interactions.reshares.trigger("change");
      expect(app.views.SinglePostInteractionCounts.prototype.render).toHaveBeenCalled();
    });
  });

  describe("render", function() {
    it("doesn't show a #show-all-likes link if there are no additional likes", function() {
      this.view.render();
      expect(this.view.$("#show-all-likes").length).toBe(0);
    });

    it("shows a #show-all-likes link if there are additional likes", function() {
      this.view.model.interactions.set("likes_count", this.view.model.interactions.likes.length + 1);
      this.view.render();
      expect(this.view.$("#show-all-likes").length).toBe(1);
    });

    it("doesn't show a #show-all-reshares link if there are no additional reshares", function() {
      this.view.render();
      expect(this.view.$("#show-all-reshares").length).toBe(0);
    });

    it("shows a #show-all-reshares link if there are additional reshares", function() {
      this.view.model.interactions.set("reshares_count", this.view.model.interactions.reshares.length + 1);
      this.view.render();
      expect(this.view.$("#show-all-reshares").length).toBe(1);
    });
  });

  describe("showAllLikes", function() {
    it("is called when clicking #show-all-likes", function() {
      spyOn(this.view, "showAllLikes");
      this.view.delegateEvents();
      this.view.model.interactions.set("likes_count", this.view.model.interactions.likes.length + 1);
      this.view.render();
      expect(this.view.showAllLikes).not.toHaveBeenCalled();
      this.view.$("#show-all-likes").click();
      expect(this.view.showAllLikes).toHaveBeenCalled();
    });

    it("calls _showAll", function() {
      spyOn(this.view, "_showAll");
      this.view.showAllLikes($.Event());
      expect(this.view._showAll).toHaveBeenCalledWith("likes", this.view.model.interactions.likes);
    });
  });

  describe("showAllReshares", function() {
    it("is called when clicking #show-all-reshares", function() {
      spyOn(this.view, "showAllReshares");
      this.view.delegateEvents();
      this.view.model.interactions.set("reshares_count", this.view.model.interactions.reshares.length + 1);
      this.view.render();
      expect(this.view.showAllReshares).not.toHaveBeenCalled();
      this.view.$("#show-all-reshares").click();
      expect(this.view.showAllReshares).toHaveBeenCalled();
    });

    it("calls _showAll", function() {
      spyOn(this.view, "_showAll");
      this.view.showAllReshares($.Event());
      expect(this.view._showAll).toHaveBeenCalledWith("reshares", this.view.model.interactions.reshares);
    });
  });

  describe("_showAll", function() {
    beforeEach(function() {
      this.view.model.interactions.set("likes_count", this.view.model.interactions.likes.length + 1);
      this.view.model.interactions.set("reshares_count", this.view.model.interactions.reshares.length + 1);
      this.view.render();
    });

    context("with likes", function() {
      it("hides the #show-all-likes link", function() {
        expect(this.view.$("#show-all-likes")).not.toHaveClass("hidden");
        expect(this.view.$("#show-all-reshares")).not.toHaveClass("hidden");
        this.view._showAll("likes", this.view.model.interactions.likes);
        expect(this.view.$("#show-all-likes")).toHaveClass("hidden");
        expect(this.view.$("#show-all-reshares")).not.toHaveClass("hidden");
      });

      it("shows the likes loader", function() {
        expect(this.view.$("#likes .loader")).toHaveClass("hidden");
        expect(this.view.$("#reshares .loader")).toHaveClass("hidden");
        this.view._showAll("likes", this.view.model.interactions.likes);
        expect(this.view.$("#likes .loader")).not.toHaveClass("hidden");
        expect(this.view.$("#reshares .loader")).toHaveClass("hidden");
      });

      it("calls #fetch on the model", function() {
        spyOn(this.view.model.interactions.likes, "fetch");
        this.view._showAll("likes", this.view.model.interactions.likes);
        expect(this.view.model.interactions.likes.fetch).toHaveBeenCalled();
      });

      it("triggers 'change' after a successfull fetch", function() {
        spyOn(this.view.model.interactions.likes, "trigger");
        this.view._showAll("likes", this.view.model.interactions.likes);
        jasmine.Ajax.requests.mostRecent().respondWith({status: 200, responseText: "{\"id\": 1}"});
        expect(this.view.model.interactions.likes.trigger).toHaveBeenCalledWith("change");
      });
    });

    context("with reshares", function() {
      it("hides the #show-all-reshares link", function() {
        expect(this.view.$("#show-all-likes")).not.toHaveClass("hidden");
        expect(this.view.$("#show-all-reshares")).not.toHaveClass("hidden");
        this.view._showAll("reshares", this.view.model.interactions.reshares);
        expect(this.view.$("#show-all-likes")).not.toHaveClass("hidden");
        expect(this.view.$("#show-all-reshares")).toHaveClass("hidden");
      });

      it("shows the reshares loader", function() {
        expect(this.view.$("#likes .loader")).toHaveClass("hidden");
        expect(this.view.$("#reshares .loader")).toHaveClass("hidden");
        this.view._showAll("reshares", this.view.model.interactions.reshares);
        expect(this.view.$("#likes .loader")).toHaveClass("hidden");
        expect(this.view.$("#reshares .loader")).not.toHaveClass("hidden");
      });

      it("calls #fetch on the model", function() {
        spyOn(this.view.model.interactions.reshares, "fetch");
        this.view._showAll("reshares", this.view.model.interactions.reshares);
        expect(this.view.model.interactions.reshares.fetch).toHaveBeenCalled();
      });

      it("triggers 'change' after a successfull fetch", function() {
        spyOn(this.view.model.interactions.reshares, "trigger");
        this.view._showAll("reshares", this.view.model.interactions.reshares);
        jasmine.Ajax.requests.mostRecent().respondWith({status: 200, responseText: "{\"id\": 1}"});
        expect(this.view.model.interactions.reshares.trigger).toHaveBeenCalledWith("change");
      });
    });
  });
});
