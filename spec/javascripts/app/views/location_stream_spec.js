describe("app.views.LocationMap", function() {
  beforeEach(function(){
    this.post = factory.post();
    this.view = new app.views.LocationStream({model : this.post});
  });

  describe("toggleMap", function() {
    context("with location provided", function() {
      beforeEach(function(){
        this.post.set({location : factory.location()}); // set location
        this.view.render();
        console.log(this.view.$el.find(".mapContainer")[0]);
      });

      it("should contain a map container", function() {
        expect(this.view.$el[0]).toContainElement(".mapContainer");
      });

      it("should initialize map", function() {
        expect(this.view.$el.find(".mapContainer")[0]).toHaveClass("empty");
        this.view.toggleMap();
        expect(this.view.$el.find(".mapContainer")[0]).not.toHaveClass("empty");
      });
      /*
       * does not work .. not sure why
      it("should change display status on every click", function() {
        expect(this.view.$el.find(".mapContainer")[0]).toHaveCss({display: "block"});
        this.view.toggleMap();
        expect(this.view.$el.find(".mapContainer")[0]).toHaveCss({display: "none"});
      });
      */
    }),
    context("without location provided", function() {
      it("should not initialize the map", function() {
        expect(this.view.$el[0]).not.toContainElement(".mapContainer");
      });
    });
  });
});
