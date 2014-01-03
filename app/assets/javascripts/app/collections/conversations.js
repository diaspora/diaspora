app.collections.Conversations = Backbone.Collection.extend({
  model: app.models.Conversation,
  url: '/conversations',

  sync: function(method, model, options) {
    var options = options || {};
    options.headers = {'Accept': gon.backboneMimeType};
    return Backbone.sync(method, model, options);
  }
});
