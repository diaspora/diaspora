app.collections.Messages = Backbone.Collection.extend({
  model: app.models.Message,

  comparator: function(msg1, msg2) {
    var u1 = msg1.get('updated_at');
    var u2 = msg2.get('updated_at');

    if( u1 < u2  ) return -1;
    if( u1 == u2 ) return 0;
    return 1;
  },

  sync: function(method, model, options) {
    var options = options || {};
    options.headers = {'Accept': gon.backboneMimeType};
    return Backbone.sync(method, model, options);
  }
});
