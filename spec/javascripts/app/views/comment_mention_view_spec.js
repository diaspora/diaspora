describe("app.views.CommentMention", function() {
  describe("initialize", function() {
    it("passes correct URL to PublisherMention contructor", function() {
      spyOn(app.views.PublisherMention.prototype, "initialize");
      new app.views.CommentMention({postId: 123});
      var call = app.views.PublisherMention.prototype.initialize.calls.mostRecent();
      expect(call.args[0].url).toEqual("/posts/123/mentionable");
    });
  });
});
