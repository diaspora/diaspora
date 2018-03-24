(function() {
  app.helpers.locations = {
    getTiles: function() {
      // If the mapbox option is enabled in the diaspora.yml, the mapbox tiles with the podmin's credentials are used.
      if (gon.appConfig.map.mapbox.enabled) {
        return L.tileLayer("https://api.mapbox.com/styles/v1/{style}/tiles/256/{z}/{x}/{y}?access_token={accessToken}", {
          accessToken: gon.appConfig.map.mapbox.access_token,
          style: gon.appConfig.map.mapbox.style,
          attribution: "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                       "<a href='http://creativecommons.org/licenses/by-sa/2.0/''>CC-BY-SA</a>, " +
                       "Imagery © <a href='https://www.mapbox.com'>Mapbox</a>",
          maxZoom: 18
        });
      }

      // maptiles from the Heidelberg University are used by default.
      return L.tileLayer("http://korona.geog.uni-heidelberg.de/tiles/roads/x={x}&y={y}&z={z}", {
        attribution: "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                     "rendering <a href='http://giscience.uni-hd.de/'>" +
                     "GIScience Research Group @ Heidelberg University</a>",
        maxZoom: 18
      });
    }
  };
})();
