describe("app.collections.comments", function(){
  describe("url", function(){
    it("should user the post id", function(){
      var post =new app.models.Post({id : 5});
      var collection = new app.collections.Comments([], {post : post});
      expect(collection.url()).toBe("/posts/5/comments");
    });
  });
});
