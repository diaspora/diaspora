app.collections.Messages = Backbone.Collection.extend({
  model: app.models.Message,

  sync: function(method, model, options) {
    var options = options || {};
    options.headers = {'Accept': gon.backboneMimeType};
    return Backbone.sync(method, model, options);
  }
});
