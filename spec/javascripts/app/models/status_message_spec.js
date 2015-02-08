describe("app.models.StatusMessage", function(){
  describe("#url", function(){
    it("is /status_messages when its new", function(){
      var post = new app.models.StatusMessage();
      expect(post.url()).toBe("/status_messages");
    });

    it("is /posts/id when it has an id", function(){
      expect(new app.models.StatusMessage({id : 5}).url()).toBe("/posts/5");
    });
  });
});
