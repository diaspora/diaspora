(function() {
  var Comment = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, comment) {
      $.extend(self, {
        comment: comment,
        deleteCommentLink: comment.find("a.comment_delete")
      });

      self.deleteCommentLink.click(self.removeComment);
      self.deleteCommentLink.tipsy({ trigger: "hover" });
    });

    this.removeComment = function(evt) {
      evt.preventDefault();

      if(confirm(Diaspora.I18n.t("confirm_dialog"))) {
        $.post(self.deleteCommentLink.attr("href"), {
          _method: "delete"
        }, function() {
          self.comment.hide("blind", { direction: "vertical" }, 300, function() {
            self.comment.remove();
          });
        });
      }
    };
  };

  Diaspora.Widgets.Comment = Comment;
})();
