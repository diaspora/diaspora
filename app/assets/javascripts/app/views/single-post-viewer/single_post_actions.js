app.views.SinglePostActions = app.views.Feedback.extend({
  templateName: "single-post-viewer/single-post-actions",
  tooltipSelector: "time",

  events: function() {
    return _.defaults({
      "click .focus-comment" : "focusComment"
    }, app.views.Feedback.prototype.events);
  },

  renderPluginWidgets : function() {
    app.views.Base.prototype.renderPluginWidgets.apply(this);
    this.$('a').tooltip({placement: 'bottom'});
  },

  focusComment: function() {
    $('.comment_stream .comment_box').focus();
    $('html,body').animate({scrollTop: $('.comment_stream .comment_box').offset().top - ($('.comment_stream .comment_box').height() + 20)});
    return false;
  }

});
