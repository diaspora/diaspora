describe("app.models.Post.Interactions", function(){
  beforeEach(function(){
    this.interactions = factory.post().interactions;
    this.author = factory.author({guid: "loggedInAsARockstar"});
    loginAs({guid: "loggedInAsARockstar"});

    this.userLike = new app.models.Like({author : this.author});
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
  });

  describe("unlike", function(){
    it("calls destroy on the likes collection", function(){
      this.interactions.likes.add(this.userLike);
      this.interactions.unlike();

      expect(this.interactions.likes.length).toEqual(0);
    });
  });

  describe("reshare", function() {
    var ajaxSuccess = { status: 200, responseText: "{\"id\": 1}" };

    beforeEach(function(){
      this.reshare = this.interactions.post.reshare();
    });

    it("triggers a change on the model", function() {
      spyOn(this.interactions, "trigger");

      this.interactions.reshare();
      jasmine.Ajax.requests.mostRecent().respondWith(ajaxSuccess);

      expect(this.interactions.trigger).toHaveBeenCalledWith("change");
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
});
