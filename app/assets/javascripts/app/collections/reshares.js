app.collections.Reshares = Backbone.Collection.extend({
  model: app.models.Reshare,
  url : "/reshares"
});
