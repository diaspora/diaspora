app.views.StreamObject = app.views.Base.extend({
  initialize: function(options) {
    this.setupRenderEvents();
  },

  postRenderTemplate : function(){
    // collapse long posts
    this.$(".collapsible").expander({
      slicePoint: 400,
      widow: 12,
      expandPrefix: "",
      expandText: Diaspora.I18n.t("show_more"),
      userCollapse: false,
      beforeExpand: function() {
        var readMoreDiv = $(this).find('.read-more');
        var lastParagraphBeforeReadMore = readMoreDiv.prev();
        var firstParagraphAfterReadMore = $(readMoreDiv.next().find('p')[0]);

        lastParagraphBeforeReadMore.append(firstParagraphAfterReadMore.text());

        firstParagraphAfterReadMore.remove();
        readMoreDiv.remove();
      }
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
