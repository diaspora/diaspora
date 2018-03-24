describe("app.views.OpenGraph", function() {
  context("without a video_url", function() {
    beforeEach(function() {
      this.openGraphCache = {
        "url": "http://example.com/articles/123",
        "title": "Example title",
        "description": "Test description",
        "image": "http://example.com/thumb.jpg",
        "ob_type": "article"
      };
      this.statusMessage = factory.statusMessage({
        "open_graph_cache": this.openGraphCache
      });
      this.view = new app.views.OpenGraph({model: this.statusMessage});
    });

    describe("rendering", function() {
      it("shows the preview based on the opengraph data", function() {
        this.view.render();
        var html = this.view.$el.html();

        expect(html).toContain(this.openGraphCache.url);
        expect(html).toContain(this.openGraphCache.title);
        expect(html).toContain(this.openGraphCache.description);
        expect(html).toContain(this.openGraphCache.image);
        expect(html).not.toContain("video-overlay");
      });
    });
  });

  context("with a video_url", function() {
    beforeEach(function() {
      this.openGraphCache = {
        "url": "http://example.com/articles/123",
        "title": "Example title",
        "description": "Test description",
        "image": "http://example.com/thumb.jpg",
        "ob_type": "article",
        "video_url": "http://example.com"
      };
      this.statusMessage = factory.statusMessage({
        "open_graph_cache": this.openGraphCache
      });
      this.view = new app.views.OpenGraph({model: this.statusMessage});
    });

    describe("rendering", function() {
      it("shows the preview based on the opengraph data", function() {
        this.view.render();
        var html = this.view.$el.html();

        expect(html).toContain(this.openGraphCache.url);
        expect(html).toContain(this.openGraphCache.title);
        expect(html).toContain(this.openGraphCache.description);
        expect(html).toContain(this.openGraphCache.image);
        expect(html).toContain(this.openGraphCache.video_url);
        expect(html).toContain("video-overlay");
      });
    });

    describe("loadVideo", function() {
      it("adds an iframe with the video", function() {
        this.view.render();
        spec.content().html(this.view.$el);
        expect($("iframe").length).toBe(0);
        $(".video-overlay").click();
        expect($("iframe").length).toBe(1);
        expect($("iframe").attr("src")).toBe(this.openGraphCache.video_url);
      });
    });
  });
});
