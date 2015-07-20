// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.collections.Photos = Backbone.Collection.extend({
  url : "/photos",

  model: function(attrs, options) {
    var modelClass = app.models.Photo;
    return new modelClass(attrs, options);
  },

  parse: function(resp){
    return resp.photos;
  }
});
// @license-end
