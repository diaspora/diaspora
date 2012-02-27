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

});
