// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.PodEntry = app.views.Base.extend({
  templateName: "pod_table_entry",

  tagName: "tr",

  events: {
    "click .more": "toggleMore",
    "click .recheck": "recheckPod"
  },

  tooltipSelector: ".ssl-status i, .actions i",

  className: function() {
    if( this.model.get("offline") ) { return "bg-danger"; }
    if( this.model.get("status")==="version_failed" ) { return "bg-warning"; }
    if( this.model.get("status")==="no_errors" ) { return "bg-success"; }
  },

  initialize: function(opts) {
    this.parent = opts.parent;
    this.rendered = false;
    this.model.on("change", this.render, this);
  },

  presenter: function() {
    return _.extend({}, this.defaultPresenter(), {
      /* jshint camelcase: false */
      is_unchecked: (this.model.get("status")==="unchecked"),
      has_no_errors: (this.model.get("status")==="no_errors"),
      has_errors: (this.model.get("status")!=="no_errors"),
      status_text: Diaspora.I18n.t("admin.pods.states."+this.model.get("status")),
      pod_url: (this.model.get("ssl") ? "https" : "http") + "://" + this.model.get("host") +
                 (this.model.get("port") ? ":" + this.model.get("port") : ""),
      response_time_fmt: this._fmtResponseTime()
      /* jshint camelcase: true */
    });
  },

  postRenderTemplate: function() {
    if( !this.rendered ) {
      this.parent.appendChild(this.el);
    }

    this.rendered = true;
    return this;
  },

  toggleMore: function() {
    this.$(".details").toggle();
    return false;
  },

  recheckPod: function() {
    var self  = this;
    this.$el.addClass("checking");

    this.model.recheck()
      .done(function(){
        app.flashMessages.success(Diaspora.I18n.t("admin.pods.recheck.success"));
      })
      .fail(function(){
        app.flashMessages.error(Diaspora.I18n.t("admin.pods.recheck.failure"));
      })
      .always(function(){
        self.$el
          .removeClass("bg-danger bg-warning bg-success")
          .addClass(_.result(self, "className"))
          .removeClass("checking");
      });

    return false;
  },

  _fmtResponseTime: function() {
    if( this.model.get("response_time")===-1 ) {
      return Diaspora.I18n.t("admin.pods.not_available");
    }
    return Diaspora.I18n.t("admin.pods.ms", {count: this.model.get("response_time")});
  }
});

// @license-end
