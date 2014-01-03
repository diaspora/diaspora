app.models.Message = Backbone.Model.extend({
  sync: function(method, model, options) {
    var options = options || {};
    options.headers = {'Accept': gon.backboneMimeType};
    return Backbone.sync(method, model, options);
  }
});
