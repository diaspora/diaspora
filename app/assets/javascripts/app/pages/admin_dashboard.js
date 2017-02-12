// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.pages.AdminDashboard = Backbone.View.extend({
  initialize: function() {
    this.podVersionAlert = $("#pod-status .alert.pod-version");
    this.updatePodStatus();
  },

  updatePodStatus: function() {
    var self = this,
        tagName = "";
    $.get("https://api.github.com/repos/diaspora/diaspora/releases/latest")
      .done(function(data) {
        // the response might be malformed
        try {
          /* jshint camelcase: false */
          tagName = data.tag_name;
          /* jshint camelcase: true */
          if(tagName.charAt(0) !== "v") {
            self.updatePodStatusFail();
            return;
          }
        } catch(e) {
          self.updatePodStatusFail();
          return;
        }

        // split version into components
        self.latestVersion = tagName.slice(1).split(".").map(Number);
        if(self.podUpToDate() === null) {
          self.updatePodStatusFail();
        } else {
          self.updatePodStatusSuccess();
        }
      })
      .fail(function() {
        self.updatePodStatusFail();
      });
  },

  updatePodStatusSuccess: function() {
    this.podVersionAlert.removeClass("alert-info");
    var podStatusMessage = Diaspora.I18n.t("admins.dashboard.up_to_date");
    if(this.podUpToDate()) {
      this.podVersionAlert.addClass("alert-success");
    } else {
      podStatusMessage = Diaspora.I18n.t("admins.dashboard.outdated");
      this.podVersionAlert.addClass("alert-danger");
    }
    this.podVersionAlert
      .html("<strong>" + podStatusMessage + "</strong>")
      .append(" ")
      .append(Diaspora.I18n.t("admins.dashboard.compare_versions", {
        latestVersion: "v" + this.latestVersion.join("."),
        podVersion: "v" + gon.podVersion
      }));
  },

  updatePodStatusFail: function() {
    this.podVersionAlert
      .removeClass("alert-info")
      .addClass("alert-warning")
      .text(Diaspora.I18n.t("admins.dashboard.error"));
  },

  podUpToDate: function() {
    var podVersion = gon.podVersion.split(/\.|\-/).map(Number);
    if(this.latestVersion.length < 4 || podVersion.length < 4) { return null; }
    for(var i = 0; i < 4; i++) {
      if(this.latestVersion[i] < podVersion[i]) { return true; }
      if(this.latestVersion[i] > podVersion[i]) { return false; }
    }
    return true;
  }
});
// @license-end
