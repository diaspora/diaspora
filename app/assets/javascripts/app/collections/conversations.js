app.collections.Conversations = Backbone.Collection.extend({
  model: app.models.Conversation,
  url: '/conversations',

  comparator: function(conv1, conv2) {
    var u1 = conv1.get('updated_at');
    var u2 = conv2.get('updated_at');

    if( u1 < u2  ) return 1;
    if( u1 == u2 ) return 0;
    return -1;
  },

  sync: function(method, model, options) {
    var options = options || {};
    options.headers = {'Accept': gon.backboneMimeType};
    return Backbone.sync(method, model, options);
  }
});
