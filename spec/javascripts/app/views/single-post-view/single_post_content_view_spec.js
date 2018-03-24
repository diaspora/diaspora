describe("app.views.SinglePostContent", function() {
  beforeEach(function() {
    this.post = factory.post();
    this.view = new app.views.SinglePostContent({model: this.post});
  });

  describe("map", function() {
    context("with location provided", function() {
      beforeEach(function() {
        this.post.set({location: factory.location()});
        spec.content().html(this.view.render().el);
        gon.appConfig = {map: {mapbox: {enabled: false}}};
      });

      it("initializes the leaflet map", function() {
        spyOn(L, "map").and.callThrough();
        this.view.map();
        expect(L.map).toHaveBeenCalled();
      });

      it("should add a map container", function() {
        expect(spec.content()).toContainElement(".mapContainer");
      });
    });

    context("without location provided", function() {
      beforeEach(function() {
        spec.content().html(this.view.render().el);
      });

      it("doesn't initialize the leaflet map", function() {
        spyOn(L, "map");
        this.view.map();
        expect(L.map).not.toHaveBeenCalled();
      });

      it("shouldn't add a map container", function() {
        expect(spec.content()).not.toContainElement(".mapContainer");
      });
    });
  });
});
