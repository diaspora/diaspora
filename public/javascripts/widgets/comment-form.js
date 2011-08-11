(function() {
  var CommentForm = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, commentFormElement) {
      $.extend({
        commentFormElement: commentFormElement
      });

      self.commentFormElement.submit(self.submitComment);
    });

    this.submitComment = function(evt) {
      evt.preventDefault();

      $.post(self.commentFormElement.attr("action"), self.commentFormElement.serialize(), function() {

      });
    }
  };

  Diaspora.Widgets.CommentForm = CommentForm;
})();