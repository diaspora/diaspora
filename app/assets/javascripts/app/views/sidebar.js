// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Sidebar = app.views.Base.extend({
  el: ".info-bar",

  events: {
    "click input#invite_code": "selectInputText",
    "click .section .title": "toggleSection"
  },

  selectInputText: function(event) {
    event.target.select();
  },

  toggleSection: function(e) {
    $(e.target).closest(".section").toggleClass("collapsed");
  }
});
// @license-end
