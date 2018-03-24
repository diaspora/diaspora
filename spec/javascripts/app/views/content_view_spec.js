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

  // These tests don't work in PhantomJS because it doesn't support HTML5 <video>.
  if (/PhantomJS/.exec(navigator.userAgent) === null) {
    describe("onVideoThumbClick", function() {
      beforeEach(function() {
        this.post = new app.models.StatusMessage({text: "[title](https://www.w3schools.com/html/mov_bbb.mp4)"});
        this.view = new app.views.StatusMessage({model: this.post});

        this.view.render();
      });

      afterEach(function() {
        this.view.$("video").stop();
      });

      it("hides video overlay", function() {
        expect(this.view.$(".video-overlay").length).toBe(1);
        this.view.$(".media-embed .thumb").click();
        expect(this.view.$(".video-overlay")).toHaveClass("hidden");
      });

      it("expands posts on click", function() {
        this.view.$(".collapsible").height(500);
        this.view.collapseOversized();

        expect(this.view.$(".collapsed").length).toBe(1);
        this.view.$(".media-embed .thumb").click();
        expect(this.view.$(".opened").length).toBe(1);
      });

      it("plays video", function(done) {
        this.view.$("video").on("playing", function() {
          done();
        });

        this.view.$(".media-embed .thumb").click();
      });
    });
  }
});
