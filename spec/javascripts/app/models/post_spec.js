describe("app.models.Post", function() {
  beforeEach(function(){
    this.post = new app.models.Post();
  });

  describe("headline and body", function(){
    describe("headline", function(){
      beforeEach(function(){
        this.post.set({text :"     yes    "});
      });

      it("the headline is the entirety of the post", function(){
        expect(this.post.headline()).toBe("yes");
      });

      it("takes up until the new line", function(){
        this.post.set({text : "love\nis avery powerful force"});
        expect(this.post.headline()).toBe("love");
      });
    });

    describe("body", function(){
      it("takes after the new line", function(){
        this.post.set({text : "Inflamatory Title\nwith text that substantiates a less absolutist view of the title."});
        expect(this.post.body()).toBe("with text that substantiates a less absolutist view of the title.");
      });
    });
  });

  describe("createdAt", function() {
    it("returns the post's created_at as an integer", function() {
      var date = new Date();
      this.post.set({ created_at: +date * 1000 });

      expect(typeof this.post.createdAt()).toEqual("number");
      expect(this.post.createdAt()).toEqual(+date);
    });
  });
});
