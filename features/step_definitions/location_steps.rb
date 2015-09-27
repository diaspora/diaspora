When /^I allow geolocation$/ do
  page.execute_script <<-JS
    navigator.geolocation.getCurrentPosition = function(success) {
      success({coords: {latitude: 42.42424242, longitude: 3.14159}});
    };
  JS
end
