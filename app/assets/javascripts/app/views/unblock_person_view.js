// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.UnblockPerson = app.views.Base.extend({
  templateName: "unblock_person",

  events: {
    "click #unblock_user_button": "unblock"
  },

  initialize: function(opts) {
    _.extend(this, opts);
    this.parent = opts.parent;
  },

  unblock: function() {
    var unblock = this.person.unblock();
    var that = this;

    unblock.fail(function() {
      app.flashMessages.error(Diaspora.I18.t("unblock_failed"));
    });

    unblock.done(function() {
      that.parent._populateHovercard();
    });
    return false;
  }
});
// @license-end
