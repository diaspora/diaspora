# frozen_string_literal: true

When /^I allow geolocation$/ do
  page.execute_script <<-JS
    OSM.Locator = function() {
      return {
        getAddress: function(callback) {
          callback("locator address", {latitude: 42.42424242, longitude: 3.14159});
        }
      }
    }
  JS
end
