app.views.StreamObject = app.views.Base.extend({
  initialize: function(options) {
    this.setupRenderEvents();
  },

  postRenderTemplate : function(){
    // collapse long posts
    this.$(".collapsible").expander({
      slicePoint: 400,
      widow: 12,
      expandText: Diaspora.I18n.t("show_more"),
      userCollapse: false
    });
  },

  destroyModel: function(evt){
    if(evt){ evt.preventDefault(); }
    if(!confirm(Diaspora.I18n.t("confirm_dialog"))) { return }

    this.model.destroy();
    this.slideAndRemove();
  },

  slideAndRemove : function(){
    $(this.el).slideUp(400, function(){
      $(this).remove();
    });
  }
});
