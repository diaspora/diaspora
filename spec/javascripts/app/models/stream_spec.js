describe("app.models.Stream", function() {
  beforeEach(function(){
    this.stream = new app.models.Stream(),
    this.expectedPath = document.location.pathname;
  })

  describe(".fetch", function() {
    var postFetch
    beforeEach(function(){
      postFetch = new $.Deferred()

      spyOn(this.stream.items, "fetch").andCallFake(function(){
        return postFetch
      })
    })

    it("it fetches posts from the window's url, and ads them to the collection", function() {
      this.stream.fetch()
      expect(this.stream.items.fetch).toHaveBeenCalledWith({ add : true, url : this.expectedPath});
    });

    it("returns the json path with max_time if the collection has models", function() {
      var post = new app.models.Post();
      spyOn(post, "createdAt").andReturn(1234);
      this.stream.add(post);

      this.stream.fetch()
      expect(this.stream.items.fetch).toHaveBeenCalledWith({ add : true, url : this.expectedPath + "?max_time=1234"});
    });

    it("triggers fetched on the stream when it is fetched", function(){
      var fetchedSpy = jasmine.createSpy()
      this.stream.bind('fetched', fetchedSpy)
      this.stream.fetch()
      postFetch.resolve([1,2,3])
      expect(fetchedSpy).toHaveBeenCalled()
    })

    it("triggers allItemsLoaded on the stream when zero posts are returned", function(){
      var fetchedSpy = jasmine.createSpy()
      this.stream.bind('allItemsLoaded', fetchedSpy)
      this.stream.fetch()
      postFetch.resolve([])
      expect(fetchedSpy).toHaveBeenCalled()
    })

    it("triggers allItemsLoaded on the stream when a Post is returned", function(){
      var fetchedSpy = jasmine.createSpy()
      this.stream.bind('allItemsLoaded', fetchedSpy)
      this.stream.fetch()
      postFetch.resolve(factory.post().attributes)
      expect(fetchedSpy).toHaveBeenCalled()
    })
  });
});
