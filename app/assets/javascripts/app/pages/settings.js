// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.pages.Settings = Backbone.View.extend({
  initialize: function() {
    $(".settings_visibility").tooltip({placement: "top"});
    $(".profile-visibility-hint").tooltip({placement: "top"});
    $("[name='profile[public_details]']").bootstrapSwitch();
  }
});
// @license-end
