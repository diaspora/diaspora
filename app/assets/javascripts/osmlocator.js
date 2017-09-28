// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

OSM =  {};

OSM.Locator = function(){

  var geolocalize = function(callback){
    navigator.geolocation.getCurrentPosition(function(position) {
      var lat=position.coords.latitude,
          lon=position.coords.longitude;
      $.getJSON("https://nominatim.openstreetmap.org/reverse?format=json&lat="+lat+"&lon="+lon+"&addressdetails=3", function(data){
        return callback(data.display_name, position.coords);
      });
    },errorGettingPosition);
  };

  function errorGettingPosition() {
    $("#location").remove();
  }

  return {
    getAddress: geolocalize
  };
};
// @license-end
