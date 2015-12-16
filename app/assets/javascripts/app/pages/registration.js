// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.pages.Registration = Backbone.View.extend({
  initialize: function() {
    $("input#user_email").popover({
      placement: "left",
      trigger: "focus"
    }).popover("show");
  }
});
// @license-end
