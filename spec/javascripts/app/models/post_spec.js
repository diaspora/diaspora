describe("app.models.Post", function() {
  beforeEach(function(){
    this.post = new app.models.Post();
  })

  describe("url", function(){
    it("should be /posts when it doesn't have an id", function(){
      expect(new app.models.Post().url()).toBe("/posts")
    })
  
    it("should be /posts/id when it doesn't have an id", function(){
      expect(new app.models.Post({id: 5}).url()).toBe("/posts/5")
    })
  })
  describe("createdAt", function() {
    it("returns the post's created_at as an integer", function() {
      var date = new Date;
      this.post.set({ created_at: +date * 1000 });

      expect(typeof this.post.createdAt()).toEqual("number");
      expect(this.post.createdAt()).toEqual(+date);
    });
  });

  describe("toggleLike", function(){
    it("calls unliked when the user_like exists", function(){
      this.post.set({user_like : "123"});
      spyOn(this.post, "unlike").andReturn(true);

      this.post.toggleLike();
      expect(this.post.unlike).toHaveBeenCalled();
    })

    it("calls liked when the user_like does not exist", function(){
      this.post.set({user_like : null});
      spyOn(this.post, "like").andReturn(true);

      this.post.toggleLike();
      expect(this.post.like).toHaveBeenCalled();
    })
  })

  describe("like", function(){
    it("calls create on the likes collection", function(){
      spyOn(this.post.likes, "create");

      this.post.like();
      expect(this.post.likes.create).toHaveBeenCalled();
    })
  })

  describe("unlike", function(){
    it("calls destroy on the likes collection", function(){
      var like = new app.models.Like();
      this.post.set({user_like : like.toJSON()})

      spyOn(app.models.Like.prototype, "destroy");

      this.post.unlike();
      expect(app.models.Like.prototype.destroy).toHaveBeenCalled();
    })
  })
});
