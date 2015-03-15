// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Location = Backbone.View.extend({

  el: "#location",

  initialize: function(){
    this.render();
    this.getLocation();
  },

  render: function(){
    $(this.el).append('<img alt="ajax-loader" src="'+ImagePaths.get('ajax-loader.gif')+'">');
  },

  getLocation: function(){
    var element = this.el;

    var locator = new OSM.Locator();
    locator.getAddress(function(address, latlng){
      $(element).html('<input id="location_address" type="text" class="input-block-level" value="' + address + '"/>');
      $('#location_coords').val(latlng.latitude + "," + latlng.longitude);
    });
  },
});
// @license-end

