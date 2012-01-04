app.views.StreamObject = app.views.Base.extend({

  initialize: function(options) {
    this.model.bind('remove', this.remove, this);
    this.model.bind('change', this.render, this);
  },

  destroyModel: function(evt){
    if(evt){ evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t("confirm_dialog"))) { return }

    this.model.destroy();

    $(this.el).slideUp(400, function(){
      $(this).remove();
    });
  }
});
