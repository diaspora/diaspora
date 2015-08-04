// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.LocationMap = app.views.Content.extend({
  templateName: "status-message-map",

  map: function() {
      var location = this.model.get("location");

      // if (coordinates != "" && tileserver.enable) {  // for when the tileserver is set via the diaspora.yml
      if (location.lat) {
        var tileLayerSource = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token={accessToken}";
        var map = L.map("map").setView([location.lat, location.lng], 16);
        var attribution = "Map data &copy; <a href='http://openstreetmap.org'>OpenStreetMap</a> contributors, " +
                          "<a href='http://creativecommons.org/licenses/by-sa/2.0/''>CC-BY-SA</a>, " +
                          "Imagery © <a href='http://mapbox.com'>Mapbox</a>";

        L.tileLayer(tileLayerSource, {
          attribution:  attribution,
          maxZoom: 18,
          id: "zaziemo.mpn66kn8",
          accessToken: "pk.eyJ1IjoiemF6aWVtbyIsImEiOiI3ODVjMzVjNmM2ZTU3YWM3YTE5YWYwMTRhODljM2M1MSJ9.-nVgyS4PLnV4m9YkvMB5wA"
        }).addTo(map);

        var markerOnMap = L.marker(location).addTo(map);

        return map;
      }
  },

  postRenderTemplate : function(){
      _.defer(_.bind(this.map, this));
  }
});
// @license-end
