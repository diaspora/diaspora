describe("app.models.Post", function() {
  beforeEach(function(){
    this.post = new app.models.Post();
  })

  describe("headline and body", function(){
    describe("headline", function(){
      beforeEach(function(){
        this.post.set({text :"     yes    "})
      })

      it("the headline is the entirety of the post", function(){
        expect(this.post.headline()).toBe("yes")
      })

      it("takes up until the new line", function(){
        this.post.set({text : "love\nis avery powerful force"})
        expect(this.post.headline()).toBe("love")
      })
    })

    describe("body", function(){
      it("takes after the new line", function(){
        this.post.set({text : "Inflamatory Title\nwith text that substantiates a less absolutist view of the title."})
        expect(this.post.body()).toBe("with text that substantiates a less absolutist view of the title.")
      })
    })
  })

  describe("createdAt", function() {
    it("returns the post's created_at as an integer", function() {
      var date = new Date;
      this.post.set({ created_at: +date * 1000 });

      expect(typeof this.post.createdAt()).toEqual("number");
      expect(this.post.createdAt()).toEqual(+date);
    });
  });

  describe("hasPhotos", function(){
    it('returns true if the model has more than one photo', function(){
      this.post.set({photos : [1,2]})
      expect(this.post.hasPhotos()).toBeTruthy()
    })

    it('returns false if the model does not have any photos', function(){
      this.post.set({photos : []})
      expect(this.post.hasPhotos()).toBeFalsy()
    })
  });

  describe("hasText", function(){
    it('returns true if the model has text', function(){
      this.post.set({text : "hella"})
      expect(this.post.hasText()).toBeTruthy()
    })

    it('returns false if the model does not have text', function(){
      this.post.set({text : "    "})
      expect(this.post.hasText()).toBeFalsy()
    })
  });
});
