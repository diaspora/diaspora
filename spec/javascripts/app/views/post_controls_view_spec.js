describe("app.views.PostControls", function() {
  describe("render", function() {
    beforeEach(function() {
      this.model = factory.post();
      this.view = new app.views.PostControls({model: this.model});
    });

    context("in a post of the current user", function() {
      beforeEach(function() {
        app.currentUser = new app.models.User(this.model.attributes.author);
        this.view.render();
      });

      it("shows a delete button", function() {
        expect(this.view.$(".delete.remove_post").length).toBe(1);
      });

      it("doesn't show a report button", function() {
        expect(this.view.$(".post_report").length).toBe(0);
      });

      it("doesn't show an ignore button", function() {
        expect(this.view.$(".block_user").length).toBe(0);
      });

      it("doesn't show participation buttons", function() {
        expect(this.view.$(".create_participation").length).toBe(0);
        expect(this.view.$(".destroy_participation").length).toBe(0);
      });

      it("doesn't show a hide button", function() {
        expect(this.view.$(".delete.hide_post").length).toBe(0);
      });
    });

    context("in a post of another user", function() {
      beforeEach(function() {
        this.view.render();
      });

      it("doesn't show a delete button", function() {
        expect(this.view.$(".delete.remove_post").length).toBe(0);
      });

      it("shows a report button", function() {
        expect(this.view.$(".post_report").length).toBe(1);
      });

      it("shows an ignore button", function() {
        expect(this.view.$(".block_user").length).toBe(1);
      });

      it("shows a create participation button", function() {
        expect(this.view.$(".create_participation").length).toBe(1);
        expect(this.view.$(".destroy_participation").length).toBe(0);
      });

      it("shows a destroy participation button if the user participated", function() {
        this.model.set({participation: true});
        this.view.render();
        expect(this.view.$(".create_participation").length).toBe(0);
        expect(this.view.$(".destroy_participation").length).toBe(1);
      });

      it("shows a hide button", function() {
        expect(this.view.$(".delete.hide_post").length).toBe(1);
      });
    });
  });

  describe("events", function() {
    beforeEach(function() {
      this.model = factory.post();
    });

    it("calls destroyModel when removing a post", function() {
      spyOn(app.views.PostControls.prototype, "destroyModel").and.callThrough();
      spyOn(app.views.Post.prototype, "destroyModel");
      app.currentUser = new app.models.User(this.model.attributes.author);
      this.postView = new app.views.Post({model: this.model});
      this.view = new app.views.PostControls({model: this.model, post: this.postView});
      this.view.render();
      this.view.$(".remove_post.delete").click();
      expect(app.views.PostControls.prototype.destroyModel).toHaveBeenCalled();
      expect(app.views.Post.prototype.destroyModel).toHaveBeenCalled();
    });

    it("calls hidePost when hiding a post", function() {
      spyOn(app.views.PostControls.prototype, "hidePost");
      this.view = new app.views.PostControls({model: this.model});
      this.view.render();
      this.view.$(".hide_post.delete").click();
      expect(app.views.PostControls.prototype.hidePost).toHaveBeenCalled();
    });

    it("calls report when reporting a post", function() {
      spyOn(app.views.PostControls.prototype, "report");
      this.view = new app.views.PostControls({model: this.model});
      this.view.render();
      this.view.$(".post_report").click();
      expect(app.views.PostControls.prototype.report).toHaveBeenCalled();
    });

    it("calls blockUser when blocking the user", function() {
      spyOn(app.views.PostControls.prototype, "blockUser");
      this.view = new app.views.PostControls({model: this.model});
      this.view.render();
      this.view.$(".block_user").click();
      expect(app.views.PostControls.prototype.blockUser).toHaveBeenCalled();
    });

    it("calls createParticipation when creating a participation", function() {
      spyOn(app.views.PostControls.prototype, "createParticipation");
      this.view = new app.views.PostControls({model: this.model});
      this.view.render();
      this.view.$(".create_participation").click();
      expect(app.views.PostControls.prototype.createParticipation).toHaveBeenCalled();
    });

    it("calls destroyParticipation when destroying a participation", function() {
      spyOn(app.views.PostControls.prototype, "destroyParticipation");
      this.model.set({participation: true});
      this.view = new app.views.PostControls({model: this.model});
      this.view.render();
      this.view.$(".destroy_participation").click();
      expect(app.views.PostControls.prototype.destroyParticipation).toHaveBeenCalled();
    });
  });

  describe("initialize", function() {
    it("rerenders the view when the model has been changed", function() {
      spyOn(app.views.PostControls.prototype, "render");
      this.model = factory.post();
      this.view = new app.views.PostControls({model: this.model});
      expect(app.views.PostControls.prototype.render).not.toHaveBeenCalled();
      this.model.trigger("change");
      expect(app.views.PostControls.prototype.render).toHaveBeenCalled();
    });
  });

  describe("blockUser", function() {
    beforeEach(function() {
      spyOn(window, "confirm").and.returnValue(true);
      this.model = factory.post();
      this.view = new app.views.PostControls({model: this.model});
      this.view.render();
    });

    it("asks for a confirmation", function() {
      this.view.blockUser();
      expect(window.confirm).toHaveBeenCalledWith(Diaspora.I18n.t("ignore_user"));
    });

    it("calls blockAuthor", function() {
      spyOn(this.model, "blockAuthor").and.callThrough();
      this.view.blockUser();
      expect(this.model.blockAuthor).toHaveBeenCalled();
    });

    it("doesn't redirect to the stream page on success", function() {
      spyOn(app, "_changeLocation");
      this.view.blockUser();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(app._changeLocation).not.toHaveBeenCalled();
    });

    it("redirects to the stream page on success from the single post view", function() {
      spyOn(app, "_changeLocation");
      this.view.singlePost = true;
      this.view.blockUser();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(app._changeLocation).toHaveBeenCalledWith(Routes.stream());
    });

    it("shows a flash message when errors occur", function() {
      spyOn(app.flashMessages, "error");
      this.view.blockUser();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 422});
      expect(app.flashMessages.error).toHaveBeenCalledWith(Diaspora.I18n.t("ignore_failed"));
    });
  });

  describe("hidePost", function() {
    beforeEach(function() {
      spyOn(window, "confirm").and.returnValue(true);
      this.postView = {remove: function() { return; }};
      this.model = factory.post();
      this.view = new app.views.PostControls({model: this.model, post: this.postView});
      this.view.render();
    });

    it("asks for a confirmation", function() {
      this.view.hidePost();
      expect(window.confirm).toHaveBeenCalledWith(Diaspora.I18n.t("confirm_dialog"));
    });

    it("sends an ajax request with the correct post id", function() {
      this.view.hidePost();
      expect(jasmine.Ajax.requests.mostRecent().url).toBe(Routes.shareVisibility(42));
      expect(jasmine.Ajax.requests.mostRecent().data().post_id).toEqual(["" + this.model.get("id")]);
      expect(jasmine.Ajax.requests.mostRecent().method).toBe("PUT");
    });

    it("removes the post on success", function() {
      spyOn(this.view.post, "remove");
      spyOn(app, "_changeLocation");
      this.view.hidePost();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(this.view.post.remove).toHaveBeenCalled();
      expect(app._changeLocation).not.toHaveBeenCalled();
    });

    it("redirects to the stream page on success from the single post view", function() {
      spyOn(this.view.post, "remove");
      spyOn(app, "_changeLocation");
      this.view.singlePost = true;
      this.view.hidePost();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(this.view.post.remove).not.toHaveBeenCalled();
      expect(app._changeLocation).toHaveBeenCalledWith(Routes.stream());
    });

    it("shows a flash message when errors occur", function() {
      spyOn(app.flashMessages, "error");
      this.view.hidePost();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 422});
      expect(app.flashMessages.error).toHaveBeenCalledWith(Diaspora.I18n.t("hide_post_failed"));
    });
  });
});
