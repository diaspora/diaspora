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
});
