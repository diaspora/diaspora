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
    var ajax_success = { status: 200, responseText: [] };

    beforeEach(function(){
      this.reshare = this.interactions.post.reshare();
    });

    it("triggers a change on the model", function() {
      spyOn(this.interactions, "trigger");

      this.interactions.reshare();
      jasmine.Ajax.requests.mostRecent().respondWith(ajax_success);

      expect(this.interactions.trigger).toHaveBeenCalledWith("change");
    });

    it("adds the reshare to the stream", function() {
      app.stream = { addNow: $.noop };
      spyOn(app.stream, "addNow");
      this.interactions.reshare();
      jasmine.Ajax.requests.mostRecent().respondWith(ajax_success);

      expect(app.stream.addNow).toHaveBeenCalledWith(this.reshare);
    });
  });
});
