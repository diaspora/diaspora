describe("app.models.Post.Interactions", function(){
  var ajaxSuccess = {status: 200, responseText: "{\"id\": 1}"};
  var ajaxNoContent = {status: 204};

  beforeEach(function(){
    this.post = factory.post();
    this.interactions = this.post.interactions;
    this.author = factory.author({guid: "loggedInAsARockstar"});
    loginAs({guid: "loggedInAsARockstar"});
    spec.content().append($("<div id='flash-container'>"));
    app.flashMessages = new app.views.FlashMessages({el: spec.content().find("#flash-container")});

    this.userLike = new app.models.Like({author: this.author, id: "id01"});
  });

  describe("toggleLike", function(){
    it("calls unliked when the user_like exists", function(){
      spyOn(this.interactions, "unlike").and.returnValue(true);
      this.interactions.likes.add(this.userLike);
      this.interactions.toggleLike();

      expect(this.interactions.unlike).toHaveBeenCalled();
    });

    it("calls liked when the user_like does not exist", function(){
      spyOn(this.interactions, "like").and.returnValue(true);
      this.interactions.likes.reset([]);
      this.interactions.toggleLike();

      expect(this.interactions.like).toHaveBeenCalled();
    });
  });

  describe("like", function(){
    it("calls create on the likes collection", function(){
      this.interactions.like();
      expect(this.interactions.likes.length).toEqual(1);
    });

    it("sets the participation flag for the post", function() {
      expect(this.post.get("participation")).toBeFalsy();
      this.interactions.like();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
      expect(this.post.get("participation")).toBeTruthy();
    });

    it("triggers a change on the likes collection", function() {
      spyOn(this.interactions.likes, "trigger");
      this.interactions.like();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
      expect(this.interactions.likes.trigger).toHaveBeenCalledWith("change");
    });

    it("displays a flash message on errors", function() {
      spyOn(app.flashMessages, "handleAjaxError").and.callThrough();
      this.interactions.like();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "error message"});

      expect(app.flashMessages.handleAjaxError).toHaveBeenCalled();
      expect(app.flashMessages.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("error message");
      expect(spec.content().find(".flash-message")).toBeErrorFlashMessage("error message");
    });
  });

  describe("unlike", function(){
    beforeEach(function() {
      this.interactions.likes.add(this.userLike);
      this.post.set({participation: true});
      spyOn(this.interactions, "userLike").and.returnValue(this.userLike);
    });

    it("calls delete on the likes collection for the post", function() {
      expect(this.interactions.likes.length).toEqual(1);
      this.interactions.unlike();
      expect(this.interactions.likes.length).toEqual(0);
    });

    it("sets the participation flag for the post", function() {
      expect(this.post.get("participation")).toBeTruthy();
      this.interactions.unlike();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxNoContent);
      expect(this.post.get("participation")).toBeFalsy();
    });

    it("triggers a change on the likes collection", function() {
      spyOn(this.interactions.likes, "trigger");
      this.interactions.unlike();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxNoContent);
      expect(this.interactions.likes.trigger).toHaveBeenCalledWith("change");
    });

    it("displays a flash message on errors", function() {
      spyOn(app.flashMessages, "handleAjaxError").and.callThrough();
      this.interactions.unlike();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "error message"});

      expect(app.flashMessages.handleAjaxError).toHaveBeenCalled();
      expect(app.flashMessages.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("error message");
      expect(spec.content().find(".flash-message")).toBeErrorFlashMessage("error message");
    });
  });

  describe("reshare", function() {
    beforeEach(function(){
      this.reshare = this.interactions.post.reshare();
    });

    it("triggers a change on the interactions model", function() {
      spyOn(this.interactions, "trigger");

      this.interactions.reshare();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);

      expect(this.interactions.trigger).toHaveBeenCalledWith("change");
    });

    it("triggers a change on the reshares collection", function() {
      spyOn(this.interactions.reshares, "trigger");
      this.interactions.reshare();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
      expect(this.interactions.reshares.trigger).toHaveBeenCalledWith("change");
    });

    it("adds the reshare to the default, activity and aspects stream", function() {
      app.stream = { addNow: $.noop };
      spyOn(app.stream, "addNow");
      var self = this;
      ["/stream", "/activity", "/aspects"].forEach(function(path) {
        app.stream.basePath = function() { return path; };
        self.interactions.reshare();
        jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);

        expect(app.stream.addNow).toHaveBeenCalledWith({id: 1});
      });
    });

    it("doesn't add the reshare to any other stream", function() {
      app.stream = { addNow: $.noop };
      spyOn(app.stream, "addNow");
      var self = this;
      ["/followed_tags", "/mentions/", "/tag/diaspora", "/people/guid/stream"].forEach(function(path) {
        app.stream.basePath = function() { return path; };
        self.interactions.reshare();
        jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
        expect(app.stream.addNow).not.toHaveBeenCalled();
      });
    });

    it("sets the participation flag for the post", function() {
      expect(this.post.get("participation")).toBeFalsy();
      this.interactions.reshare();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
      expect(this.post.get("participation")).toBeTruthy();
    });

    it("displays a flash message on errors", function() {
      spyOn(app.flashMessages, "handleAjaxError").and.callThrough();
      this.interactions.reshare();
      jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "error message"});

      expect(app.flashMessages.handleAjaxError).toHaveBeenCalled();
      expect(app.flashMessages.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("error message");
      expect(spec.content().find(".flash-message")).toBeErrorFlashMessage("error message");
    });
  });

  describe("userLike", function(){
    beforeEach(function() {
      this.interactions.likes.reset([]);
    });

    it("returns false if no user liked the post", function() {
      expect(this.interactions.userLike()).toBeFalsy();
    });

    it("returns true if only the current user liked the post", function() {
      this.interactions.likes.add(this.userLike);
      expect(this.interactions.userLike()).toBeTruthy();
    });

    it("returns false if only another user liked the post", function() {
      var anotherAuthor = factory.author({guid: "anotherAuthor"});
      var anotherLike = new app.models.Like({author : anotherAuthor});
      this.interactions.likes.add(anotherLike);
      expect(this.interactions.userLike()).toBeFalsy();
    });

    it("returns true if the current user and another user liked the post", function() {
      var anotherAuthor = factory.author({guid: "anotherAuthor"});
      var anotherLike = new app.models.Like({author : anotherAuthor});
      this.interactions.likes.add(anotherLike);
      this.interactions.likes.add(this.userLike);
      expect(this.interactions.userLike()).toBeTruthy();
    });

    it("returns false if only a broken like exists", function() {
      var brokenLike = new app.models.Like();
      this.interactions.likes.add(brokenLike);
      expect(this.interactions.userLike()).toBeFalsy();
    });

    it("returns true if the current user liked the post and there is a broken like", function() {
      var brokenLike = new app.models.Like();
      this.interactions.likes.add(brokenLike);
      this.interactions.likes.add(this.userLike);
      expect(this.interactions.userLike()).toBeTruthy();
    });
  });

  describe("userReshare", function(){
    beforeEach(function() {
      this.interactions.reshares.reset([]);
      this.userReshare = new app.models.Reshare({author : this.author});
    });

    it("returns false if no user reshared the post", function() {
      expect(this.interactions.userReshare()).toBeFalsy();
    });

    it("returns true if only the current user reshared the post", function() {
      this.interactions.reshares.add(this.userReshare);
      expect(this.interactions.userReshare()).toBeTruthy();
    });

    it("returns false if only another user reshared the post", function() {
      var anotherAuthor = factory.author({guid: "anotherAuthor"});
      var anotherReshare = new app.models.Reshare({author : anotherAuthor});
      this.interactions.reshares.add(anotherReshare);
      expect(this.interactions.userReshare()).toBeFalsy();
    });

    it("returns true if the current user and another user reshared the post", function() {
      var anotherAuthor = factory.author({guid: "anotherAuthor"});
      var anotherReshare = new app.models.Reshare({author : anotherAuthor});
      this.interactions.reshares.add(anotherReshare);
      this.interactions.reshares.add(this.userReshare);
      expect(this.interactions.userReshare()).toBeTruthy();
    });

    it("returns false if only a broken reshare exists", function() {
      var brokenReshare = new app.models.Reshare();
      this.interactions.reshares.add(brokenReshare);
      expect(this.interactions.userReshare()).toBeFalsy();
    });

    it("returns true if the current user reshared the post and there is a broken reshare", function() {
      var brokenReshare = new app.models.Reshare();
      this.interactions.reshares.add(brokenReshare);
      this.interactions.reshares.add(this.userReshare);
      expect(this.interactions.userReshare()).toBeTruthy();
    });
  });

  describe("comment", function() {
    it("calls make on the comments collection", function() {
      spyOn(this.interactions.comments, "make").and.callThrough();
      this.interactions.comment("text");
      expect(this.interactions.comments.make).toHaveBeenCalledWith("text");
    });

    context("on success", function() {
      it("sets the participation flag for the post", function() {
        expect(this.post.get("participation")).toBeFalsy();
        this.interactions.comment("text");
        jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
        expect(this.post.get("participation")).toBeTruthy();
      });

      it("increases the comments count", function() {
        var commentsCount = this.interactions.get("comments_count");
        this.interactions.comment("text");
        jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
        expect(this.interactions.get("comments_count")).toBe(commentsCount + 1);
      });

      it("triggers a change on the model", function() {
        spyOn(this.interactions, "trigger");
        this.interactions.comment("text");
        jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
        expect(this.interactions.trigger).toHaveBeenCalledWith("change");
      });

      it("calls the success function if one is given", function() {
        var success = jasmine.createSpy();
        this.interactions.comment("text", {success: success});
        jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);
        expect(success).toHaveBeenCalled();
      });
    });

    context("on error", function() {
      it("doesn't set the participation flag for the post", function() {
        expect(this.post.get("participation")).toBeFalsy();
        this.interactions.comment("text");
        jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
        expect(this.post.get("participation")).toBeFalsy();
      });

      it("doesn't increase the comments count", function() {
        var commentsCount = this.interactions.get("comments_count");
        this.interactions.comment("text");
        jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
        expect(this.interactions.get("comments_count")).toBe(commentsCount);
      });

      it("doesn't trigger a change on the model", function() {
        spyOn(this.interactions, "trigger");
        this.interactions.comment("text");
        jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
        expect(this.interactions.trigger).not.toHaveBeenCalledWith("change");
      });

      it("calls the error function if one is given", function() {
        var error = jasmine.createSpy();
        this.interactions.comment("text", {error: error});
        jasmine.Ajax.requests.mostRecent().respondWith({status: 400});
        expect(error).toHaveBeenCalled();
      });

      it("displays a flash message", function() {
        spyOn(app.flashMessages, "handleAjaxError").and.callThrough();
        this.interactions.comment("text");
        jasmine.Ajax.requests.mostRecent().respondWith({status: 400, responseText: "error message"});

        expect(app.flashMessages.handleAjaxError).toHaveBeenCalled();
        expect(app.flashMessages.handleAjaxError.calls.argsFor(0)[0].responseText).toBe("error message");
        expect(spec.content().find(".flash-message")).toBeErrorFlashMessage("error message");
      });
    });
  });
});
