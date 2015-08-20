// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.LocationStream = app.views.Content.extend({
  events: {
    "click .near-from": "toggleMap"
  },
  templateName: "status-message-location",

  toggleMap: function () {
    if (gon.appConfig.map.enabled){
      var mapContainer = this.$el.find(".mapContainer");

      if (mapContainer.hasClass("empty")) {
        var location = this.model.get("location");
        mapContainer.css("height", "150px");

        if (location.lat) {
          var tileLayerSource = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}";
          var map = L.map(mapContainer[0]).setView([location.lat, location.lng], 16);
          var attribution = "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                            "<a href='http://creativecommons.org/licenses/by-sa/2.0/''>CC-BY-SA</a>, " +
                            "Imagery © <a href='http://mapbox.com'>Mapbox</a>";

          L.tileLayer(tileLayerSource, {
            attribution:  attribution,
            maxZoom: 18,
            id: gon.appConfig.map.mapbox.id,
            accessToken: gon.appConfig.map.mapbox.accessToken
          }).addTo(map);

          var markerOnMap = L.marker(location).addTo(map);
          mapContainer.removeClass("empty");
          return map;
        }
      } else {
          if (mapContainer.css("display") === "none") {
          mapContainer.css("display", "block");
          } else {
            mapContainer.css("display", "none");
          }
        }
      }
    }
});
// @license-end
