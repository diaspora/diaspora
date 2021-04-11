(function() {
  app.helpers.locations = {
    getTiles: function() {
      // If the mapbox option is enabled in the diaspora.toml, the mapbox tiles with the podmin's credentials are used.
      if (gon.appConfig.map.mapbox.enabled) {
        return L.tileLayer(
          "https://api.mapbox.com/styles/v1/{style}/tiles/256/{z}/{x}/{y}?access_token={accessToken}",
          {
            accessToken: gon.appConfig.map.mapbox.access_token,
            style: gon.appConfig.map.mapbox.style,
            attribution:
              "Map data &copy; <a href='https://openstreetmap.org'>OpenStreetMap</a> contributors, " +
              "<a href='http://opendatacommons.org/licenses/dbcl/1.0/'>Open Database License, ODbL 1.0</a>, " +
              "Imagery © <a href='https://www.mapbox.com'>Mapbox</a>",
            maxZoom: 18,
            tileSize: 512,
            zoomOffset: -1
          }
        );
      }
    }
  };
})();
