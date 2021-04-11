describe("app.helpers.locations", function() {
  describe("getTiles", function() {
    context("with mapbox enabled", function() {
      beforeEach(function() {
        /* eslint-disable camelcase */
        gon.appConfig = {map: {mapbox: {enabled: true, style: "mapbox/streets-v11", access_token: "yourAccessToken"}}};
        /* eslint-enable camelcase */
      });

      it("returns tiles from mapbox", function() {
        var tiles = app.helpers.locations.getTiles();
        expect(tiles._url).toMatch("https://api.mapbox.com/");
      });
    });
  });
});
