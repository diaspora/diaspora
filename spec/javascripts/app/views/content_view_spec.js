describe("app.views.Content", function(){
  beforeEach(function(){
    this.post = new app.models.StatusMessage();
    this.view = new app.views.Content({model : this.post});
  });

  describe("rendering", function(){
    it("should return all but the first photo from the post", function() {
      this.post.set({photos : [1,2]}); // set 2 Photos
      expect(this.view.smallPhotos().length).toEqual(1);
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
  });
});
