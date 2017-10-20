# frozen_string_literal: true

When /^I allow geolocation$/ do
  page.execute_script <<-JS
    window.navigator = {
      geolocation: {
        getCurrentPosition: function(success) {
          success({coords: {latitude: 42.42424242, longitude: 3.14159}});
        }
      }
    };

    $.getJSON = function(url, myCallback) {
      if (url === "https://nominatim.openstreetmap.org/reverse?format=json&lat=42.42424242&lon=3.14159&addressdetails=3") {
        return myCallback({display_name: "locator address"});
      }
    };
  JS
end
