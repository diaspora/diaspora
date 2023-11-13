// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

app.views.Base = Backbone.View.extend({

  initialize : function() {
    this.setupRenderEvents();
    this.setupReport();
  },

  presenter : function(){
    return this.defaultPresenter();
  },

  setupRenderEvents : function(){
    // this line is too generic.  we usually only want to re-render on
    // feedback changes as the post content, author, and time do not change.
    //
    // this.model.bind('change', this.render, this);
  },

  defaultPresenter : function(){
    var modelJson = this.model && this.model.attributes ? _.clone(this.model.attributes) : {};

    return _.extend(modelJson, {
      current_user : app.currentUser.attributes,
      loggedIn : app.currentUser.authenticated()
    });
  },

  render : function() {
    this.renderTemplate();
    this.renderSubviews();
    this.renderPluginWidgets();
    this.removeTooltips();

    return this;
  },

  renderTemplate : function(){
    var presenter = _.isFunction(this.presenter) ? this.presenter() : this.presenter;
    this.template = HandlebarsTemplates[this.templateName+"_tpl"];

    if (this.templateName === false) {
      return;
    }

    if (!this.templateName) {
      throw new Error("No templateName set, set to false to ignore.");
    }

    if (!this.template) {
      throw new Error("Invalid templateName provided: " + this.templateName);
    }

    this.$el
      .html(this.template(presenter))
      .attr("data-template", _.last(this.templateName.split("/")));

    this.setupAvatarFallback(this.$el);

    // add placeholder support for old browsers
    this.$("input, textarea").placeholder();

    // init autosize plugin
    autosize(this.$("textarea"));

    this.postRenderTemplate();
  },

  postRenderTemplate: $.noop, //hella callbax yo

  renderSubviews : function(){
    var self = this;
    _.each(this.subviews, function(property, selector){
      var view = _.isFunction(self[property]) ? self[property]() : self[property];
      if (view && self.$(selector).length > 0) {
        self.$(selector).empty();
        self.$(selector).html(view.render().el);
        view.delegateEvents();
      }
    });
  },

  renderPluginWidgets : function() {
    this.$(this.tooltipSelector).tooltip();
    this.$("time").timeago();
  },

  removeTooltips : function() {
    $(".tooltip").remove();
  },

  setFormAttrs : function(){
    function setValueFromField(memo, attribute, selector){
      if(attribute.slice("-2") === "[]") {
        memo[attribute.slice(0, attribute.length - 2)] = _.pluck(this.$el.find(selector).serializeArray(), "value");
      } else {
        memo[attribute] = this.$el.find(selector).val() || this.$el.find(selector).text();
      }
      return memo;
    }

    this.model.set(_.inject(this.formAttrs, _.bind(setValueFromField, this), {}));
  },

  setupReport: function() {
    const reportForm = document.getElementById("report-content-form");
    if (reportForm) {
      reportForm.addEventListener("submit", this.onSubmitReport);
    }
  },

  onSubmitReport: function(ev) {
    if (ev) { ev.preventDefault(); }
    const form = ev.currentTarget;
    $("#reportModal").modal("hide");
    const textarea = document.getElementById("report-reason-field");
    const report = {
      item_id: form.dataset.reportId,
      item_type: form.dataset.reportType,
      text: textarea.value
    };

    new app.models.Report().save({report: report}, {
      success: function() {
        app.flashMessages.success(Diaspora.I18n.t("report.status.created"));
      },
      error: function() {
        app.flashMessages.error(Diaspora.I18n.t("report.status.exists"));
      }
    });
  },

  report: function(evt) {
    if (evt) { evt.preventDefault(); }
    const form = document.getElementById("report-content-form");
    form.dataset.reportId = this.model.id;
    form.dataset.reportType = evt.currentTarget.dataset.type;
    document.getElementById("report-reason-field").value = "";
    document.getElementById("report-reason-field").focus();
    $("#reportModal").modal();
  },

  destroyConfirmMsg: function() { return Diaspora.I18n.t("confirm_dialog"); },

  destroyModel: function(evt) {
    evt && evt.preventDefault();
    const url = this.model.urlRoot + "/" + this.model.id;

    if( confirm(_.result(this, "destroyConfirmMsg")) ) {
      this.$el.addClass("deleting");
      this.model.destroy({
        url: url,
        success: function() {
          this.remove();
        }.bind(this),
        error: function() {
          this.$el.removeClass("deleting");
          app.flashMessages.error(Diaspora.I18n.t("failed_to_remove"));
        }.bind(this)
      });
    }
  },

  avatars: {
    fallback: function() {
      $(this).attr("src", ImagePaths.get("user/default.png"));
    },
    selector: "img.avatar"
  },

  setupAvatarFallback: function(el) {
    el.find(this.avatars.selector).on("error", this.avatars.fallback);
  }
});

app.views.StaticContentView = app.views.Base.extend({
  initialize : function(options) {
    this.templateName = options.templateName;
    this.data = options.data;

    return this;
  },

  presenter : function(){
    return this.data;
  },
});
// @license-end
