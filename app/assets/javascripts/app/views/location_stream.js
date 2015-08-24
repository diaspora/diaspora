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
          // If the mapbox option is enabled in the defaults the mapbox tiles with the podmin's credentials are used.
          // If mapbox is not enabled the OpenMapSurfer tiles are used, which don't need credentials.
          var mapsource = gon.appConfig.map.mapbox.enabled ? gon.appConfig.map.mapbox : "";
          var tileLayerSource = mapsource ? "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}"
                                          : "http://korona.geog.uni-heidelberg.de/tiles/roads/x={x}&y={y}&z={z}";
          var tileAttribution = mapsource ? "<a href='https://www.mapbox.com'>Mapbox</a>"
                                          : "<a href='http://korona.geog.uni-heidelberg.de/contact.html'>OpenMapSurfer</a>";
          var attribution = "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                            "<a href='http://creativecommons.org/licenses/by-sa/2.0/''>CC-BY-SA</a>, " +
                            "Imagery © "+ tileAttribution;

          var map = L.map(mapContainer[0]).setView([location.lat, location.lng], 14);
          L.tileLayer(tileLayerSource, {
            id: mapsource.id,
            accessToken: mapsource.access_token,
            attribution:  attribution,
            maxZoom: 18,
          }).addTo(map);

          var markerOnMap = L.marker(location).addTo(map);
          mapContainer.removeClass("empty");
          return map;
        }
      } else {
          mapContainer.toggle();
        }
      }
    }
});
// @license-end
