// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.views.Location = Backbone.View.extend({

  el: "#location",

  initialize: function(){
    this.render();
    this.getLocation();
  },

  render: function(){
    $(this.el).append('<img alt="delete location" src="/assets/ajax-loader.gif">');
  },

  getLocation: function(e){
    element = this.el;

    locator = new OSM.Locator();
    locator.getAddress(function(address, latlng){
      $(element).html('<input id="location_address" value="' + address + '"/>');
      $('#location_coords').val(latlng.latitude + "," + latlng.longitude);
      $(element).append('<a id="hide_location"><img alt="delete location" src="/assets/deletelabel.png"></a>');
    });
  },
});
// @license-end
