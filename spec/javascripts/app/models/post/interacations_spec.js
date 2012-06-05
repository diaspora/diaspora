describe("app.models.Post.Interactions", function(){
  beforeEach(function(){
    this.interactions = factory.post()
    this.interactions = this.interactions.interactions
    this.author = factory.author({guid: "loggedInAsARockstar"})
    loginAs({guid: "loggedInAsARockstar"})

    this.userLike = new app.models.Like({author : this.author})
  })
  
  describe("toggleLike", function(){
    it("calls unliked when the user_like exists", function(){
      this.interactions.likes.add(this.userLike)
      spyOn(this.interactions, "unlike").andReturn(true);
      this.interactions.toggleLike();
      expect(this.interactions.unlike).toHaveBeenCalled();
    })

    it("calls liked when the user_like does not exist", function(){
      this.interactions.likes.reset([]);
      spyOn(this.interactions, "like").andReturn(true);
      this.interactions.toggleLike();
      expect(this.interactions.like).toHaveBeenCalled();
    })
  })

  describe("like", function(){
    it("calls create on the likes collection", function(){
      spyOn(this.interactions.likes, "create");

      this.interactions.like();
      expect(this.interactions.likes.create).toHaveBeenCalled();
    })
  })

  describe("unlike", function(){
    it("calls destroy on the likes collection", function(){
      this.interactions.likes.add(this.userLike)
      spyOn(this.userLike, "destroy");

      this.interactions.unlike();
      expect(this.userLike.destroy).toHaveBeenCalled();
    })
  })
})