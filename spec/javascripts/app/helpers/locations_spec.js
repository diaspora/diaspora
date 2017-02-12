describe("app.helpers.locations", function() {
  describe("getTiles", function() {
    context("with mapbox disabled", function() {
      beforeEach(function() {
        gon.appConfig = {map: {mapbox: {enabled: false}}};
      });

      it("returns tiles from the Heidelberg University", function() {
        var tiles = app.helpers.locations.getTiles();
        expect(tiles._url).toMatch("http://korona.geog.uni-heidelberg.de/");
        expect(tiles._url).not.toMatch("https://api.tiles.mapbox.com/");
      });
    });

    context("with mapbox enabled", function() {
      beforeEach(function() {
        /* eslint-disable camelcase */
        gon.appConfig = {map: {mapbox: {enabled: true, style: "mapbox/streets-v9", access_token: "yourAccessToken"}}};
        /* eslint-enable camelcase */
      });

      it("returns tiles from mapbox", function() {
        var tiles = app.helpers.locations.getTiles();
        expect(tiles._url).toMatch("https://api.mapbox.com/");
        expect(tiles._url).not.toMatch("http://korona.geog.uni-heidelberg.de/");
      });
    });
  });
});
