app.collections.Conversations = Backbone.Collection.extend({
  model: app.models.Conversation,
  url: '/conversations',

  sync: function(method, model, options) {
    var options = options || {};
    // TODO: get the header value from the mime type defined in Rails
    options.headers = {'Accept': gon.backboneMimeType};
    return Backbone.sync(method, model, options);
  }
});
