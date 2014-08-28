app.views.Location = Backbone.View.extend({

  el: "#location",

  initialize: function(){
    this.render();
    this.getLocation();
  },

  render: function(){
    $(this.el).append('<img alt="delete location" src="'+ImagePaths.get('ajax-loader.gif')+'">');
  },

  getLocation: function(e){
    element = this.el;

    locator = new OSM.Locator();
    locator.getAddress(function(address, latlng){
      $(element).html('<input id="location_address" type="text" class="input-block-level" value="' + address + '"/>');
      $('#location_coords').val(latlng.latitude + "," + latlng.longitude);
      $(element).append('<a id="hide_location"><img alt="delete location" src="'+ImagePaths.get('deletelabel.png')+'"></a>');
    });
  },
});

