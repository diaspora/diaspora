describe("app.models.Post", function() {
  beforeEach(function(){
    this.post = new app.models.Post();
  })

  describe("createdAt", function() {
    it("returns the post's created_at as an integer", function() {
      var date = new Date;
      this.post.set({ created_at: +date * 1000 });

      expect(typeof this.post.createdAt()).toEqual("number");
      expect(this.post.createdAt()).toEqual(+date);
    });
  });

  describe("baseGuid", function(){
    it("returns the post's guid if the post does not have a root", function() {
      this.post.attributes.root = null;
      this.post.attributes.guid = "abcd";

      expect(this.post.baseGuid()).toBe("abcd")
    })

    it("returns the post's root guid if the post has a root", function() {
      this.post.attributes.root = {guid : "1234"}
      this.post.attributes.guid = "abcd";

      expect(this.post.baseGuid()).toBe("1234")
    })
  })

  describe("baseAuthor", function(){
    it("returns the post's guid if the post does not have a root", function() {
      this.post.attributes.root = null;
      this.post.attributes.author = "abcd";

      expect(this.post.baseAuthor()).toBe("abcd")
    })

    it("returns the post's root guid if the post has a root", function() {
      this.post.attributes.root = {author : "1234"}
      this.post.attributes.author = "abcd";

      expect(this.post.baseAuthor()).toBe("1234")
    })
  })
});
