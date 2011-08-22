(function() {
  var Comment = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, comment) {
      $.extend(self, {
        comment: comment,
        deleteCommentLink: comment.find(".comment_delete"),
        timeAgo: self.instantiate("TimeAgo", comment.find("abbr.timeago"))
      });

      self.deleteCommentLink.click(self.removeComment);
    });

    this.removeComment = function(evt) {
      evt.preventDefault();

      $.post(self.deleteCommentLink.attr("href"), {
        _method: "delete"
      }, function() {
        self.comment.hide("blind", { direction: "vertical" }, 300, function() {
          self.comment.remove();
        });
      });
    };
  };

  Diaspora.Widgets.Comment = Comment;
})();