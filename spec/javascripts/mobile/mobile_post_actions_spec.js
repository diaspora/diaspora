describe("Diaspora.Mobile.PostActions", function(){
  describe("initialize", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_public_post");
      spyOn(Diaspora.Mobile.PostActions, "onLike");
      spyOn(Diaspora.Mobile.PostActions, "onReshare");
      Diaspora.Mobile.PostActions.initialize();
    });

    it("binds the events", function(){
      $(".stream .like-action").trigger("tap");
      expect(Diaspora.Mobile.PostActions.onLike).toHaveBeenCalled();
      $(".stream .like-action").click();
      expect(Diaspora.Mobile.PostActions.onLike).toHaveBeenCalled();
      $(".stream .reshare-action").trigger("tap");
      expect(Diaspora.Mobile.PostActions.onReshare).toHaveBeenCalled();
      $(".stream .reshare-action").click();
      expect(Diaspora.Mobile.PostActions.onReshare).toHaveBeenCalled();
    });
  });

  describe("toggleActive", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_public_post");
      Diaspora.Mobile.PostActions.initialize();
      this.link = $(".stream .like-action").first();
    });

    it("toggles active and inactive classes", function(){
      expect(this.link).toHaveClass("inactive");
      expect(this.link).not.toHaveClass("active");
      Diaspora.Mobile.PostActions.toggleActive(this.link);
      expect(this.link).not.toHaveClass("inactive");
      expect(this.link).toHaveClass("active");
      Diaspora.Mobile.PostActions.toggleActive(this.link);
      expect(this.link).toHaveClass("inactive");
      expect(this.link).not.toHaveClass("active");
    });
  });

  describe("showLoader and hideLoader", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_public_post");
      Diaspora.Mobile.PostActions.initialize();
      this.link = $(".stream .like-action").first();
    });

    it("adds and removes loading class", function(){
      expect(this.link).not.toHaveClass("loading");
      Diaspora.Mobile.PostActions.showLoader(this.link);
      expect(this.link).toHaveClass("loading");
      Diaspora.Mobile.PostActions.hideLoader(this.link);
      expect(this.link).not.toHaveClass("loading");
    });
  });

  describe("onLike", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_public_post");
      spyOn(Diaspora.Mobile.PostActions, "like");
      spyOn(Diaspora.Mobile.PostActions, "unlike");
      Diaspora.Mobile.PostActions.initialize();
      this.link = $(".stream .like-action").first();
    });

    it("doesn't activate the link if loading", function(){
      this.link.addClass("loading");
      this.link.click();
      expect(Diaspora.Mobile.PostActions.like).not.toHaveBeenCalled();
      expect(Diaspora.Mobile.PostActions.unlike).not.toHaveBeenCalled();
    });

    it("calls like if like button is inactive", function(){
      this.link.removeClass("active").addClass("inactive");
      this.link.click();
      expect(Diaspora.Mobile.PostActions.like).toHaveBeenCalled();
    });

    it("calls unlike if like button is active", function(){
      this.link.removeClass("inactive").addClass("active");
      this.link.click();
      expect(Diaspora.Mobile.PostActions.unlike).toHaveBeenCalled();
    });
  });

  describe("like", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_public_post");
      Diaspora.Mobile.PostActions.initialize();
      this.link = $(".stream .like-action").first();
      this.likeCounter = this.link.find(".like-count");
    });

    it("always calls showLoader before sending request", function(){
      spyOn(Diaspora.Mobile.PostActions, "showLoader");

      Diaspora.Mobile.PostActions.like(this.likeCounter, this.link);
      expect(Diaspora.Mobile.PostActions.showLoader).toHaveBeenCalled();
    });

    it("always calls hideLoader after receiving response", function(){
      spyOn(Diaspora.Mobile.PostActions, "hideLoader");

      Diaspora.Mobile.PostActions.like(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect(Diaspora.Mobile.PostActions.hideLoader).toHaveBeenCalled();
      Diaspora.Mobile.PostActions.like(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 201, responseText: "{\"id\": \"18\"}"});
      expect(Diaspora.Mobile.PostActions.hideLoader).toHaveBeenCalled();
    });

    it("doesn't activate the link on error", function(){
      spyOn(Diaspora.Mobile.PostActions, "toggleActive");

      Diaspora.Mobile.PostActions.like(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect(Diaspora.Mobile.PostActions.toggleActive).not.toHaveBeenCalled();
      expect(this.likeCounter.text()).toBe("0");
    });

    it("lets Diaspora.Mobile.Alert handle AJAX errors", function() {
      spyOn(Diaspora.Mobile.Alert, "handleAjaxError");
      Diaspora.Mobile.PostActions.like(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "oh noez! like failed!"});
      expect(Diaspora.Mobile.Alert.handleAjaxError).toHaveBeenCalled();
      expect(Diaspora.Mobile.Alert.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("oh noez! like failed!");
    });

    it("activates link on success", function(){
      spyOn(Diaspora.Mobile.PostActions, "toggleActive");
      var data = this.link.data("url");

      Diaspora.Mobile.PostActions.like(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 201, responseText: "{\"id\": \"18\"}"});
      expect(Diaspora.Mobile.PostActions.toggleActive).toHaveBeenCalled();
      expect(this.likeCounter.text()).toBe("1");
      expect(this.link.data("url")).toBe(data + "/18");
    });
  });

  describe("unlike", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_public_post");
      Diaspora.Mobile.PostActions.initialize();
      this.link = $(".stream .like-action").first();
      this.likeCounter = this.link.find(".like-count");
      Diaspora.Mobile.PostActions.like(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 201, responseText: "{\"id\": \"18\"}"});
    });

    it("always calls showLoader before sending request", function(){
      spyOn(Diaspora.Mobile.PostActions, "showLoader");
      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      expect(Diaspora.Mobile.PostActions.showLoader).toHaveBeenCalled();
    });

    it("always calls hideLoader after receiving response", function(){
      spyOn(Diaspora.Mobile.PostActions, "hideLoader");

      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect(Diaspora.Mobile.PostActions.hideLoader).toHaveBeenCalled();
      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(Diaspora.Mobile.PostActions.hideLoader).toHaveBeenCalled();
    });

    it("doesn't unlike on error", function(){
      spyOn(Diaspora.Mobile.PostActions, "toggleActive");

      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect(Diaspora.Mobile.PostActions.toggleActive).not.toHaveBeenCalled();
      expect(this.likeCounter.text()).toBe("1");
    });

    it("lets Diaspora.Mobile.Alert handle AJAX errors", function() {
      spyOn(Diaspora.Mobile.Alert, "handleAjaxError");
      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "oh noez! unlike failed!"});
      expect(Diaspora.Mobile.Alert.handleAjaxError).toHaveBeenCalled();
      expect(Diaspora.Mobile.Alert.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("oh noez! unlike failed!");
    });

    it("deactivates link on success", function(){
      spyOn(Diaspora.Mobile.PostActions, "toggleActive");
      var data = this.link.data("url");

      expect(this.likeCounter.text()).toBe("1");
      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(Diaspora.Mobile.PostActions.toggleActive).toHaveBeenCalled();
      expect(this.likeCounter.text()).toBe("0");
      expect(this.link.data("url")).toBe(data.replace(/\/\d+$/, ""));
    });

    it("doesn't produce negative like count", function(){
      expect(this.likeCounter.text()).toBe("1");
      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(this.likeCounter.text()).toBe("0");
      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(this.likeCounter.text()).toBe("0");
      Diaspora.Mobile.PostActions.unlike(this.likeCounter, this.link);
      jasmine.Ajax.requests.mostRecent().respondWith({status: 204});
      expect(this.likeCounter.text()).toBe("0");
    });
  });

  describe("onReshare", function(){
    beforeEach(function(){
      spec.loadFixture("aspects_index_mobile_public_post");
      Diaspora.Mobile.PostActions.initialize();
      this.reshareLink = $(".stream .reshare-action");
      spyOn(window, "confirm").and.returnValue(true);
    });

    it("always calls showLoader before sending request and hideLoader after receiving response", function(){
      spyOn(Diaspora.Mobile.PostActions, "hideLoader");
      spyOn(Diaspora.Mobile.PostActions, "showLoader");

      this.reshareLink.click();
      expect(Diaspora.Mobile.PostActions.showLoader).toHaveBeenCalled();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
      expect(Diaspora.Mobile.PostActions.hideLoader).toHaveBeenCalled();
      this.reshareLink.click();
      expect(Diaspora.Mobile.PostActions.showLoader).toHaveBeenCalled();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 201, responseText: "{}"});
      expect(Diaspora.Mobile.PostActions.hideLoader).toHaveBeenCalled();
    });

    it("calls toggleActive on success", function(){
      spyOn(Diaspora.Mobile.PostActions, "toggleActive");

      this.reshareLink.click();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 201, responseText: "{}"});
      expect(Diaspora.Mobile.PostActions.toggleActive).toHaveBeenCalledWith(this.reshareLink);
    });

    it("increases the reshare count on success", function() {
      spyOn(Diaspora.Mobile.PostActions, "toggleActive");
      var reshareCounter = this.reshareLink.find(".reshare-count");
      reshareCounter.text("8");

      this.reshareLink.click();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 201, responseText: "{}"});
      expect(Diaspora.Mobile.PostActions.toggleActive).toHaveBeenCalledWith(this.reshareLink);
      expect(reshareCounter.text()).toBe("9");
    });

    it("lets Diaspora.Mobile.Alert handle AJAX errors", function() {
      spyOn(Diaspora.Mobile.Alert, "handleAjaxError");
      this.reshareLink.click();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "reshare failed"});
      expect(Diaspora.Mobile.Alert.handleAjaxError).toHaveBeenCalled();
      expect(Diaspora.Mobile.Alert.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("reshare failed");
    });
  });
});
