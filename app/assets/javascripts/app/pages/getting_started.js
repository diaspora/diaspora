// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later
app.pages.GettingStarted = app.views.Base.extend({
  el: "#hello-there",

  templateName: false,

  subviews: {
    ".aspect-membership-dropdown": "aspectMembershipView"
  },

  initialize: function(opts) {
    this.inviter = opts.inviter;
    app.events.on("aspect:create", this.render, this);
  },

  aspectMembershipView: function() {
    return new app.views.AspectMembership({person: this.inviter, dropdownMayCreateNewAspect: true});
  }
});
// @license-end
