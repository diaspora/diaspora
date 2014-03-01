describe("app.models.StreamAspects", function() {
  describe("#fetch", function(){
    var fetch,
        stream;

    beforeEach(function(){
      fetch = new $.Deferred();
      stream = new app.models.StreamAspects([], {aspects_ids: [1,2]});
      spyOn(stream.items, "fetch").and.callFake(function(options){
        stream.items.set([{name: 'a'}, {name: 'b'}, {name: 'c'}], options);
        fetch.resolve();
        return fetch;
      });
    });

    it("fetches some posts", function(){
      stream.fetch();
      expect(stream.items.length).toEqual(3);
    });

    it("fetches more posts", function(){
      stream.fetch();
      expect(stream.items.length).toEqual(3);
      stream.fetch();
      expect(stream.items.length).toEqual(6);
    });
  });
});
