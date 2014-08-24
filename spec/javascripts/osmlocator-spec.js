describe("Locator", function(){
  navigator.geolocation = {};
  navigator.geolocation.getCurrentPosition = function(myCallback){
    lat = 1;
    lon = 2;
    position = { coords: { latitude: lat, longitude: lon} }
    return myCallback(position);
  };

  $.getJSON = function(url, myCallback){
    if(url == "https://nominatim.openstreetmap.org/reverse?format=json&lat=1&lon=2&addressdetails=3")
    {
      return myCallback({ display_name: 'locator address' })
    }
  }

  var osmlocator = new OSM.Locator();

  it("should return address, latitude, and longitude using getAddress method", function(){
    osmlocator.getAddress(function(display_name, coordinates){
      expect(display_name, 'locator address')
      expect(coordinates, { latitude: 1, longitude: 2 })
    })
  });
});
