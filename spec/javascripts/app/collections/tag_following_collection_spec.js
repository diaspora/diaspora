describe("app.collections.TagFollowings", function(){
  beforeEach(function(){
    this.collection = new app.collections.TagFollowings();
  })

  describe("create", function(){
    it("should not allow duplicates", function(){
      this.collection.create({"name":"name"})
      this.collection.create({"name":"name"})
      expect(this.collection.length).toBe(1)
    })
  })
})
