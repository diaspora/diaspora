app.views.StreamObject = app.views.Base.extend({
   destroyModel: function(evt) {
    if (evt) {
      evt.preventDefault();
    }
    if (!confirm(Diaspora.I18n.t("confirm_dialog"))) {
      return
    }

    this.model.destroy();
    this.slideAndRemove();
  },

  slideAndRemove : function() {
    $(this.el).slideUp(400, function() {
      $(this).remove();
    });
  }
});
