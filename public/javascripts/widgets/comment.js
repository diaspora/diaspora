(function() {
  var Comment = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, comment) {
      $.extend(self, {
        comment: comment,
        deleteCommentLink: comment.find("a.comment_delete"),
        likes: self.instantiate("Likes", comment.find(".likes_container")),
        timeAgo: self.instantiate("TimeAgo", comment.find("abbr.timeago")),
        content: comment.find(".content span")
      });

      self.deleteCommentLink.click(self.removeComment);
      self.deleteCommentLink.twipsy({ trigger: "hover" });

      // self.content.expander({
      //   slicePoint: 200,
      //   widow: 18,
      //   expandText: Diaspora.I18n.t("show_more"),
      //   userCollapse: false
      // });

      self.globalSubscribe("likes/" + self.comment.attr('id') + "/updated", function(){
        self.likes = self.instantiate("Likes", self.comment.find(".likes_container"));
      });
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
