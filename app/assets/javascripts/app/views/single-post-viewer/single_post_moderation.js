app.views.SinglePostModeration = app.views.PostControls.extend({
  templateName: "single-post-viewer/single-post-moderation",
  singlePost: true,

  renderPluginWidgets : function() {
    app.views.Base.prototype.renderPluginWidgets.apply(this);
    this.$("a").tooltip({placement: "bottom"});
  },

  destroyModel: function(evt) {
    if(evt) { evt.preventDefault(); }
    var url = this.model.urlRoot + "/" + this.model.id;

    if (confirm(Diaspora.I18n.t("remove_post"))) {
      this.model.destroy({ url: url })
        .done(function() {
          // return to stream
          document.location.href = "/stream";
        })
        .fail(function() {
          app.flashMessages.error(Diaspora.I18n.t("failed_to_remove"));
        });
    }
  },
});
