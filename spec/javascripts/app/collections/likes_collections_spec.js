describe("app.collections.Likes", function(){
  describe("url", function(){
    it("should user the post id", function(){
      var post =new app.models.Post({id : 5});
      var collection = new app.collections.Likes([], {post : post});
      expect(collection.url).toBe("/posts/5/likes");
    });
  });
});
