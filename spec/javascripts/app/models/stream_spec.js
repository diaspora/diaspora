describe("app.models.Stream", function() {
  var stream,
      expectedPath;

  beforeEach(function(){
    stream = new app.models.Stream();
    expectedPath = document.location.pathname;
  });

  describe("#_fetchOpts", function() {
    it("it fetches posts from the window's url, and ads them to the collection", function() {
      expect( stream._fetchOpts() ).toEqual({ remove: false, url: expectedPath});
    });

    it("returns the json path with max_time if the collection has models", function() {
      var post = new app.models.Post({created_at: 1234000});
      stream.add(post);

      expect( stream._fetchOpts() ).toEqual({ remove: false, url: expectedPath + "?max_time=1234"});
    });
  });

  describe("events", function() {
    var postFetch,
        fetchedSpy;

    beforeEach(function(){
      postFetch = new $.Deferred();
      fetchedSpy = jasmine.createSpy();
      spyOn(stream.items, "fetch").and.callFake(function(){
        return postFetch;
      });
    });

    it("triggers fetched on the stream when it is fetched", function(){
      stream.bind('fetched', fetchedSpy);
      stream.fetch();
      postFetch.resolve([1,2,3]);

      expect(fetchedSpy).toHaveBeenCalled();
    });

    it("triggers allItemsLoaded on the stream when zero posts are returned", function(){
      stream.bind('allItemsLoaded', fetchedSpy);
      stream.fetch();
      postFetch.resolve([]);

      expect(fetchedSpy).toHaveBeenCalled();
    });

    it("triggers allItemsLoaded on the stream when a Post is returned", function(){
      stream.bind('allItemsLoaded', fetchedSpy);
      stream.fetch();
      postFetch.resolve(factory.post().attributes);

      expect(fetchedSpy).toHaveBeenCalled();
    });
  });
});
