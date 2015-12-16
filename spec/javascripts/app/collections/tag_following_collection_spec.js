describe("app.collections.TagFollowings", function(){
  beforeEach(function(){
    this.collection = new app.collections.TagFollowings();
  });

  describe("comparator", function() {
    it("should compare in reverse order", function() {
      var a = new app.models.TagFollowing({name: "aaa"}),
          b = new app.models.TagFollowing({name: "zzz"});
      expect(this.collection.comparator(a, b)).toBeGreaterThan(0);
    });
  });

  describe("create", function(){
    it("should not allow duplicates", function(){
      this.collection.create({"name":"name"});
      this.collection.create({"name":"name"});
      expect(this.collection.length).toBe(1);
    });
  });
});
