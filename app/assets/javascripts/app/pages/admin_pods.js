// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.pages.AdminPods = app.views.Base.extend({
  templateName: "pod_table",

  tooltipSelector: "th i",

  initialize: function() {
    this.pods = new app.collections.Pods(app.parsePreload("pods"));
    this.rows = []; // contains the table row views
  },

  postRenderTemplate: function() {
    var self = this;
    this._showMessages();

    // avoid reflowing the page for every entry
    var fragment = document.createDocumentFragment();
    this.pods.each(function(pod) {
      self.rows.push(new app.views.PodEntry({
        parent: fragment,
        model: pod
      }).render());
    });
    this.$("tbody").append(fragment);

    return this;
  },

  _showMessages: function() {
    var msgs = document.createDocumentFragment();
    if( gon.uncheckedCount && gon.uncheckedCount > 0 ) {
      var unchecked = $("<div class='alert alert-info' role='alert' />")
        .append(Diaspora.I18n.t("admin.pods.unchecked", {count: gon.uncheckedCount}));
      msgs.appendChild(unchecked[0]);
    }
    if( gon.versionFailedCount && gon.versionFailedCount > 0 ) {
      var versionFailed = $("<div class='alert alert-warning' role='alert' />")
          .append(Diaspora.I18n.t("admin.pods.version_failed", {count: gon.versionFailedCount}));
      msgs.appendChild(versionFailed[0]);
    }
    if( gon.errorCount && gon.errorCount > 0 ) {
      var errors = $("<div class='alert alert-danger' role='alert' />")
        .append(Diaspora.I18n.t("admin.pods.errors", {count: gon.errorCount}));
        msgs.appendChild(errors[0]);
    }

    $("#pod-alerts").html(msgs);
  }
});

// @license-end
