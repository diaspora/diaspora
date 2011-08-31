(function() {
  var CommentForm = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, commentFormElement) {
      $.extend(self, {
        commentFormElement: commentFormElement,
        commentInput: commentFormElement.find("textarea")
      });

      self.commentInput.autoResize();
      self.commentInput.focus(self.showCommentForm);
    });

    this.showCommentForm = function() {
      self.commentFormElement.parent().removeClass("hidden");
      self.commentFormElement.addClass("open");
    };
  };

  Diaspora.Widgets.CommentForm = CommentForm;
})();