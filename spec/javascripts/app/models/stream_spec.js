describe("app.models.Stream", function() {
  var stream,
      expectedPath;

  beforeEach(function(){
    stream = new app.models.Stream();
    expectedPath = document.location.pathname;
  });

  describe("collectionOptions", function() {
    beforeEach(function() {
      this.post1 = new app.models.Post({"id": 1, "created_at": 12, "interacted_at": 123});
      this.post2 = new app.models.Post({"id": 2, "created_at": 13, "interacted_at": 123});
      this.post3 = new app.models.Post({"id": 3, "created_at": 13, "interacted_at": 122});
      this.post4 = new app.models.Post({"id": 4, "created_at": 10, "interacted_at": 100});
    });

    it("returns a comparator for posts that compares created_at and ids by default", function() {
      this.options = stream.collectionOptions();
      expect(this.options.comparator(this.post1, this.post2)).toBe(1);
      expect(this.options.comparator(this.post2, this.post1)).toBe(-1);
      expect(this.options.comparator(this.post2, this.post3)).toBe(1);
      expect(this.options.comparator(this.post3, this.post2)).toBe(-1);
      expect(this.options.comparator(this.post1, this.post4)).toBe(-1);
      expect(this.options.comparator(this.post4, this.post1)).toBe(1);
      expect(this.options.comparator(this.post1, this.post1)).toBe(0);
    });

    it("returns a comparator for posts that compares interacted_at and ids for the activity stream", function() {
      spyOn(stream, "basePath").and.returnValue("/activity");
      this.options = stream.collectionOptions();
      expect(this.options.comparator(this.post1, this.post2)).toBe(1);
      expect(this.options.comparator(this.post2, this.post1)).toBe(-1);
      expect(this.options.comparator(this.post2, this.post3)).toBe(-1);
      expect(this.options.comparator(this.post3, this.post2)).toBe(1);
      expect(this.options.comparator(this.post1, this.post4)).toBe(-1);
      expect(this.options.comparator(this.post4, this.post1)).toBe(1);
      expect(this.options.comparator(this.post1, this.post1)).toBe(0);
    });

    it("returns a comparator for posts that compares created_at and ids for tags including 'activity'", function() {
      spyOn(stream, "basePath").and.returnValue("/tags/foo-activity-bar");
      this.options = stream.collectionOptions();
      expect(this.options.comparator(this.post2, this.post3)).toBe(1);
      expect(this.options.comparator(this.post3, this.post2)).toBe(-1);
    });
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
