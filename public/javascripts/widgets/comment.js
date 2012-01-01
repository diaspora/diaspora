(function() {
  var Comment = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, comment) {
      $.extend(self, {
        comment: comment,
        timeAgo: self.instantiate("TimeAgo", comment.find("abbr.timeago")),
        content: comment.find(".content span .collapsible")
      });

      self.content.expander({
        slicePoint: 200,
        widow: 18,
        expandText: Diaspora.I18n.t("show_more"),
        userCollapse: false
      });
    });
  };

  Diaspora.Widgets.Comment = Comment;
})();
