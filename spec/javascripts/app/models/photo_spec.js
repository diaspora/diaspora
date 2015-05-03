describe("app.models.Photo", function() {
  
  beforeEach(function(){
    this.photo = new app.models.Photo();
  });

  describe("url", function(){
    it("should be /photos when it doesn't have an id", function(){
      expect(new app.models.Photo().url()).toBe("/photos");
    });
  
    it("should be /photos/id when it has an id", function(){
      expect(new app.models.Photo({id: 5}).url()).toBe("/photos/5");
    });
  });
  
  describe("createdAt", function() {
    it("returns the photo's created_at as an integer", function() {
      var date = new Date();
      this.photo.set({ created_at: +date * 1000 });

      expect(typeof this.photo.createdAt()).toEqual("number");
      expect(this.photo.createdAt()).toEqual(+date);
    });
  });
});
