// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.collections.Pods = Backbone.Collection.extend({
  model: app.models.Pod,

  comparator: function(model) {
    var host = model.get("host") || "";
    return host.toLowerCase();
  }
});
// @license-end
