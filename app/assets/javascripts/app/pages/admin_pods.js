// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.pages.AdminPods = app.views.Base.extend({
  templateName: "pod_table",

  tooltipSelector: "th i",
  events: {
    "click #show_all_pods": "showAllPods",
    "click #show_active_pods": "showActivePods",
    "click #show_invalid_pods": "showInvalidPods"
  },

  initialize: function() {
    this.pods = new app.collections.Pods(app.parsePreload("pods"));
    this.rows = []; // contains the table row views
    this.podfilter = "active";
  },

  showAllPods: function() {
    this.podfilter = "";
    this.postRenderTemplate();
    this.$("#show_all_pods").addClass("active");
    this.$("#show_active_pods").removeClass("active");
    this.$("#show_invalid_pods").removeClass("active");
  },

  showActivePods: function() {
    this.podfilter = "active";
    this.postRenderTemplate();
    this.$("#show_all_pods").removeClass("active");
    this.$("#show_active_pods").addClass("active");
    this.$("#show_invalid_pods").removeClass("active");
  },

  showBlockedPods: function() {
    this.podfilter = "blocked";
    this.postRenderTemplate();
    this.$("#show_all_pods").removeClass("active");
    this.$("#show_active_pods").removeClass("active");
    this.$("#show_invalid_pods").removeClass("active");
  },

  showInvalidPods: function() {
    this.podfilter = "invalid";
    this.postRenderTemplate();
    this.$("#show_all_pods").removeClass("active");
    this.$("#show_active_pods").removeClass("active");
    this.$("#show_invalid_pods").addClass("active");
  },

  postRenderTemplate: function() {
    var self = this;
    this._showMessages();

    // avoid reflowing the page for every entry
    var fragment = document.createDocumentFragment();
    this.$("tbody").empty();

    this.pods.each(function(pod) {
      if (self.podfilter === "" ||
        self.podfilter === "active" && pod.get("status") === "no_errors" ||
        self.podfilter === "invalid" && pod.get("status") !== "no_errors") {
        self.rows.push(new app.views.PodEntry({
          parent: fragment,
          model: pod
        }).render());
      }
    });
    this.$("tbody").append(fragment);

    return this;
  },

  _showMessages: function() {
    var msgs = document.createDocumentFragment();

    if (gon.totalCount && gon.totalCount > 0) {
      let totalPods = $("<div class='alert alert-info' role='alert' />")
        .append(Diaspora.I18n.t("admin.pods.total", {count: gon.totalCount}));
      if (gon.activeCount) {
        if (gon.activeCount === 0) {
          totalPods
            .append(" " + Diaspora.I18n.t("admin.pods.none_active"));
        }
        if (gon.activeCount === gon.totalCount) {
          totalPods
            .append(" " + Diaspora.I18n.t("admin.pods.all_active"));
        } else {
          totalPods
            .append(" " + Diaspora.I18n.t("admin.pods.active", {count: gon.activeCount}));
        }
      }
      msgs.appendChild(totalPods[0]);
    }

    if (gon.uncheckedCount && gon.uncheckedCount > 0) {
      var unchecked = $("<div class='alert alert-info' role='alert' />")
        .append(Diaspora.I18n.t("admin.pods.unchecked", {count: gon.uncheckedCount}));
      msgs.appendChild(unchecked[0]);
    }
    if (gon.versionFailedCount && gon.versionFailedCount > 0) {
      var versionFailed = $("<div class='alert alert-warning' role='alert' />")
        .append(Diaspora.I18n.t("admin.pods.version_failed", {count: gon.versionFailedCount.toLocaleString()}));
      msgs.appendChild(versionFailed[0]);
    }
    if (gon.errorCount && gon.errorCount > 0) {
      var errors = $("<div class='alert alert-danger' role='alert' />")
        .append(Diaspora.I18n.t("admin.pods.errors", {count: gon.errorCount.toLocaleString()}));
      msgs.appendChild(errors[0]);
    }

    $("#pod-alerts").html(msgs);
  }
});

// @license-end
