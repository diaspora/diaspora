// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.LocationStream = app.views.Base.extend({
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
        var map = L.map(mapContainer[0]).setView([location.lat, location.lng], 14);
        var tiles = app.helpers.locations.getTiles();

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
