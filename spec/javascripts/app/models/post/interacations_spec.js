describe("app.models.Post.Interactions", function(){
  beforeEach(function(){
    this.interactions = factory.post().interactions;
    this.author = factory.author({guid: "loggedInAsARockstar"})
    loginAs({guid: "loggedInAsARockstar"})

    this.userLike = new app.models.Like({author : this.author})
  });

  describe("toggleLike", function(){
    it("calls unliked when the user_like exists", function(){
      spyOn(this.interactions, "unlike").and.returnValue(true);
      this.interactions.likes.add(this.userLike)
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
      this.interactions.likes.add(this.userLike)
      this.interactions.unlike();

      expect(this.interactions.likes.length).toEqual(0);
    });
  });
});
