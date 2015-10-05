app.models.Favorite = Backbone.Model.extend({
  initialize: function(options) {
    this.type = options.type;
    this.urlRoot = '/posts/' + options.post_id + '/favorite';
  }
});
