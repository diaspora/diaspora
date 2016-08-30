// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.PostControls = app.views.Base.extend({
  templateName: "post-controls",
  className: "control-icons",

  events: {
    "click .remove_post": "destroyModel",
    "click .hide_post": "hidePost",
    "click .post_report": "report",
    "click .block_user": "blockUser",
    "click .create_participation": "createParticipation",
    "click .destroy_participation": "destroyParticipation"
  },

  tooltipSelector: [".post_report",
                    ".block_user",
                    ".delete",
                    ".create_participation",
                    ".destroy_participation"].join(", "),

  initialize: function(opts) {
    this.model.bind("change", this.render, this);
    this.post = opts.post;
  },

  presenter: function() {
    return _.extend(this.defaultPresenter(), {
      authorIsCurrentUser: app.currentUser.isAuthorOf(this.model)
    });
  },

  blockUser: function(evt) {
    if (evt) { evt.preventDefault(); }
    if (!confirm(Diaspora.I18n.t("ignore_user"))) { return; }

    this.model.blockAuthor().fail(function() {
      app.flashMessages.error(Diaspora.I18n.t("ignore_failed"));
    });
  },

  hidePost: function(evt) {
    if (evt) { evt.preventDefault(); }
    if (!confirm(Diaspora.I18n.t("confirm_dialog"))) { return; }

    var self = this;
    $.ajax({
      url: Routes.shareVisibility(42),
      type: "PUT",
      data: {
        /* eslint-disable camelcase */
        post_id: this.model.id
        /* eslint-enable camelcase */
      }
    }).done(function() {
      self.post.remove();
    }).fail(function() {
      app.flashMessages.error(Diaspora.I18n.t("hide_post_failed"));
    });
  },

  createParticipation: function(evt) {
    if (evt) { evt.preventDefault(); }
    var that = this;
    $.post(Routes.postParticipation(this.model.get("id")), {}, function() {
      that.model.set({participation: true});
    });
  },

  destroyParticipation: function(evt) {
    if (evt) { evt.preventDefault(); }
    var that = this;
    $.post(Routes.postParticipation(this.model.get("id")), {_method: "delete"}, function() {
      that.model.set({participation: false});
    });
  }
});
// @license-end
