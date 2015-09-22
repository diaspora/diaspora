// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.LocationStream = app.views.Content.extend({
  events: {
    "click .near-from": "toggleMap"
  },
  templateName: "status-message-location",

  toggleMap: function () {
    var mapContainer = this.$el.find(".mapContainer");

    if (mapContainer.hasClass("empty")) {
      var location = this.model.get("location");
      mapContainer.css("height", "150px");

      if (location.lat) {
        // If map function is enabled the maptiles from the Heidelberg University are used by default.

        var map = L.map(mapContainer[0]).setView([location.lat, location.lng], 14);

        var tiles = L.tileLayer("http://korona.geog.uni-heidelberg.de/tiles/roads/x={x}&y={y}&z={z}", {
          attribution: "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                        "rendering <a href='http://giscience.uni-hd.de/'>" +
                        "GIScience Research Group @ Heidelberg University</a>",
          maxZoom: 18,
        });

        // If the mapbox option is enabled in the diaspora.yml, the mapbox tiles with the podmin's credentials are used.
        if (gon.appConfig.map.mapbox.enabled) {

          tiles = L.tileLayer("https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}", {
            id: gon.appConfig.map.mapbox.id,
            /* jshint camelcase: false */
            accessToken: gon.appConfig.map.mapbox.access_token,
            /* jshint camelcase: true */
            attribution: "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                         "<a href='http://creativecommons.org/licenses/by-sa/2.0/''>CC-BY-SA</a>, " +
                         "Imagery © <a href='https://www.mapbox.com'>Mapbox</a>",
            maxZoom: 18,
          });
        }

        tiles.addTo(map);

        L.marker(location).addTo(map);
        mapContainer.removeClass("empty");
        return map;
      }
    } else {
        mapContainer.toggle();
    }
  }
});
// @license-end
