app.collections.Photos = Backbone.Collection.extend({
  url : "/photos",

  model: function(attrs, options) {
    var modelClass = app.models.Photo
    return new modelClass(attrs, options);
  },

  parse: function(resp){
    return resp.photos;
  }
});
