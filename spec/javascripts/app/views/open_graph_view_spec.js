describe("app.views.OpenGraph", function() {
  var open_graph_cache = {
    "url": "http://example.com/articles/123",
    "title": "Example title",
    "description": "Test description",
    "image": "http://example.com/thumb.jpg",
    "ob_type": "article"
  };

  beforeEach(function(){
    this.statusMessage = factory.statusMessage({
      "open_graph_cache": open_graph_cache
    });

    this.view = new app.views.OpenGraph({model : this.statusMessage})
  });

  describe("rendering", function(){
    it("shows the preview based on the opengraph data", function(){
      this.view.render();
      var html = this.view.$el.html();

      expect(html).toContain(open_graph_cache.url);
      expect(html).toContain(open_graph_cache.title);
      expect(html).toContain(open_graph_cache.description);
      expect(html).toContain(open_graph_cache.image);
    });
  });

});
