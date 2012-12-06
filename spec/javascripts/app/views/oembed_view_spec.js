describe("app.views.OEmbed", function(){
  beforeEach(function(){
    this.statusMessage = factory.statusMessage({
      "o_embed_cache":{
        "data":{
          "html":"some html",
          "thumbnail_url": "//example.com/thumb.jpg"
        }
      }
    });

    this.view = new app.views.OEmbed({model : this.statusMessage})
  });

  describe("rendering", function(){
    context("with thumb", function() {
      it("shows the thumb with overlay", function(){
        this.view.render();

        expect(this.view.$el.html()).toContain("example.com/thumb");
        expect(this.view.$el.html()).toContain("video-overlay");
      });

      it("shows the oembed html when clicking the thumb", function() {
        this.view.render();
        this.view.$('.thumb').click();

        _.defer(function() {
          expect(this.view.$el.html()).toContain("some html");
        });
      });
    });

    context("no thumb", function() {
      beforeEach(function(){
        this.statusMessage.set({"o_embed_cache" : {"data": {"html": "some html"}}});
      });

      it("provides oembed html from the model response", function(){
        this.view.render()
        expect(this.view.$el.html()).toContain("some html")
      });
    });
  });

  describe("presenter", function(){
    it("provides oembed html from the model", function(){
      expect(this.view.presenter().o_embed_html).toContain("some html")
    });

    it("does not provide oembed html from the model response if none is present", function(){
      this.statusMessage.set({"o_embed_cache" : null})
      expect(this.view.presenter().o_embed_html).toBe("");
    });
  });
});