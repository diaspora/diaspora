describe("app.views.LocationStream", function() {
  beforeEach(function(){
    this.post = factory.post();
    this.view = new app.views.LocationStream({model : this.post});
    /* eslint-disable camelcase */
    gon.appConfig = {map: {mapbox: {enabled: true, style: "mapbox/streets-v9", access_token: "yourAccessToken"}}};
    /* eslint-enable camelcase */
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

      it("should initialize map", function() {
        expect($(".mapContainer")).toHaveClass("empty");
        this.view.toggleMap();
        expect($(".mapContainer")).not.toHaveClass("empty");
      });

      it("should change display status on every click", function() {
        this.view.toggleMap();
        expect($(".mapContainer")).toHaveCss({display: "block"});
        this.view.toggleMap();
        expect($(".mapContainer")).toHaveCss({display: "none"});
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
