describe("App.Models.Stream", function() {
  describe("url", function() {
    var stream = new App.Collections.Stream(),
      expectedPath = document.location.pathname + ".json";
    it("returns the json path", function() {
      expect(stream.url()).toEqual(expectedPath);
    });

    it("returns the json path with max_time if the collection has models", function() {
      var post = new App.Models.Post();
      spyOn(post, "createdAt").andReturn(1234);

      stream.add(post);

      expect(stream.url()).toEqual(expectedPath + "?max_time=1234");
    });
  });
});
