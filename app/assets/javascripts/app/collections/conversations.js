app.collections.Conversations = Backbone.Collection.extend({
  model: app.models.Conversation,
  url: '/conversations',

  sync: function(method, model, options) {
    var options = options || {};
    options.headers = {'Accept': "application/vnd.diaspora.backbone+json"};
    console.log(options);
    return Backbone.sync(method, model, options);
  }
});
