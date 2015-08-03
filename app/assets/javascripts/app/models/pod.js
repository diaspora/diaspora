// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.models.Pod = Backbone.Model.extend({
  urlRoot: Routes.adminPods(),

  recheck: function() {
    var self = this,
        url  = Routes.adminPodRecheck(this.id).toString();

    return $.ajax({url: url, method: "POST", dataType: "json"})
      .done(function(newAttributes) {
        self.set(newAttributes);
      });
  }
});
// @license-end
