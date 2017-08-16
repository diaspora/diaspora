describe("app.views.Content", function(){
  beforeEach(function(){
    this.post = new app.models.StatusMessage();
    this.view = new app.views.Content({model : this.post});
  });

  describe("smallPhotos", function() {
    it("should return all but the first photo from the post", function() {
      this.post.set({photos : [1,2]}); // set 2 Photos
      expect(this.view.smallPhotos().length).toEqual(1);
    });

    it("shouldn't change the photos array", function() {
      this.post.set({photos: [1, 2]}); // set 2 Photos
      this.view.smallPhotos();
      expect(this.post.get("photos").length).toEqual(2);
    });
  });

  describe("presenter", function(){
    beforeEach(function(){
      this.post.set({text : ""}); // for textFormatter
    });

    it("provides isReshare", function(){
      expect(this.view.presenter().isReshare).toBeFalsy();
    });

    it("provides isReshare and be true when the post is a reshare", function(){
      this.post.set({post_type : "Reshare"});
      expect(this.view.presenter().isReshare).toBeTruthy();
    });

    it("provides location", function(){
      this.post.set({location : factory.location()});
      expect(this.view.presenter().location).toEqual(factory.location());
    });
  });
});
