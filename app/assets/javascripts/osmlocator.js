OSM =  {};

OSM.Locator = function(){

  var geolocalize = function(callback){
    navigator.geolocation.getCurrentPosition(function(position) {       
      lat=position.coords.latitude;
      lon=position.coords.longitude;
      var display_name =$.getJSON("https://nominatim.openstreetmap.org/reverse?format=json&lat="+lat+"&lon="+lon+"&addressdetails=3", function(data){
        return callback(data.display_name, position.coords);
      }); 
    },errorGettingPosition);
  };

  function errorGettingPosition(err) {
    $("#location").remove();
  };

  return {
    getAddress: geolocalize
  }

}
