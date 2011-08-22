(function() {
  var CommentStream = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, commentStream) {
      $.extend(self, {
        commentStream: commentStream,
        commentToggler: self.instantiate("CommentToggler", commentStream),
        comments: {}
      });

      self.commentStream.delegate(".new_comment", "ajax:failure", function() {
        Diaspora.Alert.show(Diaspora.I18n.t("failed_to_post_message"));
      });

      // doesn't belong here.
      self.commentStream.parents(".stream_element").delegate("a.focus_comment_textarea", "click", function(evt) {
        evt.preventDefault();

        var post = $(this).closest(".stream_element"),
          commentBlock = post.find(".new_comment_form_wrapper"),
          commentForm = commentBlock.find("form"),
          textarea = post.find(".new_comment textarea");

        if(commentBlock.hasClass("hidden")) {
          commentBlock.removeClass("hidden");
          commentForm.addClass("open");
          textarea.focus();
        } else {
          if(commentBlock.children().length <= 1) {
            commentBlock.addClass("hidden").removeClass("open");

          } else {
            textarea.focus();
          }
        }
      });

      self.instantiateCommentWidgets();
    });

    this.instantiateCommentWidgets = function() {
      self.comments = {};

      $.each(self.commentStream.find("li.comment"), function() {
        self.comments[this.id] = self.instantiate("Comment", $(this));
      });
    };
  };

  Diaspora.Widgets.CommentStream = CommentStream;
})();