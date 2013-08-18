app.views.SinglePostActions = app.views.Feedback.extend({
  templateName: "single-post-viewer/single-post-actions",

  events: function() {
    return _.defaults({
      "click .focus-comment" : "focusComment"
    }, app.views.Feedback.prototype.events);
  },

  focusComment: function() {
    $('.comment_box').focus();
    $("html, body").animate({ scrollTop: $(document).height()-$(window).height() }); // Go to the bottom.
    return false;
  }

});
