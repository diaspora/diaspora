describe("app.views.SinglePostContent", function() {
  beforeEach(function(){
    this.post = factory.post();
    this.view = new app.views.SinglePostContent({model : this.post});
    gon.appConfig = { map: {mapbox: {enabled: true, id: "yourID", accessToken: "yourAccessToken" }}};
  });

  describe("toggleMap", function() {
    context("with location provided", function() {
      beforeEach(function(){
        this.post.set({location : factory.location()}); // set location
        spec.content().html(this.view.render().el); // loads html element to the page
      });

      it("should contain a map container", function() {
        expect(spec.content()).toContainElement(".mapContainer");
      });

      it("should provide a small map", function() {
        expect($(".mapContainer")).toHaveClass("small-map");
        expect($(".mapContainer").height() < 100).toBeTruthy();
        expect($(".mapContainer")).toBeVisible();
      });

      it("should toggle class small-map on every click", function(){
        this.view.toggleMap();
        expect($(".mapContainer")).not.toHaveClass("small-map");
        this.view.toggleMap();
        expect($(".mapContainer")).toHaveClass("small-map");
      });

      it("should change height on every click", function() {
        this.view.toggleMap();
        expect($(".mapContainer").height() > 100).toBeTruthy();
        this.view.toggleMap();
        expect($(".mapContainer").height() < 100).toBeTruthy();
      });
    });

    context("without location provided", function() {
      beforeEach(function(){
        spec.content().html(this.view.render().el);
      });

      it("should not initialize the map", function() {
        expect(spec.content()).not.toContainElement(".mapContainer");
      });
    });
  });
});
