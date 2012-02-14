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

  describe("toggleFollow", function(){
    it("calls unfollow when the user_participation exists", function(){
      this.post.set({user_participation: "123"});
      spyOn(this.post, "unfollow").andReturn(true);

      this.post.toggleFollow();
      expect(this.post.unfollow).toHaveBeenCalled();
    })

    it("calls follow when the user_participation does not exist", function(){
      this.post.set({user_participation: null});
      spyOn(this.post, "follow").andReturn(true);

      this.post.toggleFollow();
      expect(this.post.follow).toHaveBeenCalled();
    })
  })

  describe("follow", function(){
    it("calls create on the participations collection", function(){
      spyOn(this.post.participations, "create");

      this.post.follow();
      expect(this.post.participations.create).toHaveBeenCalled();
    })
  })

  describe("unfollow", function(){
    it("calls destroy on the participations collection", function(){
      var participation = new app.models.Participation();
      this.post.set({user_participation : participation.toJSON()})

      spyOn(app.models.Participation.prototype, "destroy");

      this.post.unfollow();
      expect(app.models.Participation.prototype.destroy).toHaveBeenCalled();
    })
  })


});
