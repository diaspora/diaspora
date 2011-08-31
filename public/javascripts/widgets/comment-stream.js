(function() {
  var CommentStream = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, commentStream) {
      $.extend(self, {
        commentsList: commentStream.find("ul.comments"),
        commentToggler: commentStream.find(".toggle_post_comments"),
        comments: {}
      });

      self.commentsList.delegate(".new_comment", "ajax:failure", function() {
        Diaspora.Alert.show(Diaspora.I18n.t("failed_to_post_message"));
      });

      self.commentToggler.toggle(self.showComments, self.hideComments);

      self.instantiateCommentWidgets();
    });

    this.instantiateCommentWidgets = function() {
      self.comments = {};

      self.commentsList.find("li.comment").each(function() {
        self.publish("comment/added", [$("#" + this.id)]);
      });
    };

    this.showComments = function(evt) {
      evt.preventDefault();

      if(self.commentsList.hasClass("loaded")) {
        self.commentToggler.html(Diaspora.I18n.t("comments.hide"));
        self.commentsList.removeClass("hidden");
      }
      else {
        $("<img/>", { alt: "loading", src: "/images/ajax-loader.gif"}).appendTo(self.commentToggler);

        $.get(self.commentToggler.attr("href"), function(data) {
          self.commentToggler.html(Diaspora.I18n.t("comments.hide"));

          self.commentsList
            .html(data)
            .addClass("loaded")
            .removeClass("hidden");

          self.instantiateCommentWidgets();
        });
      }
    };

    this.hideComments = function(evt) {
      evt.preventDefault();

      self.commentToggler.html(Diaspora.I18n.t("comments.show"));
      self.commentsList.addClass("hidden");
    };

    this.subscribe("comment/added", function(evt, comment) {
      self.comments[comment.attr("id")] = self.instantiate("Comment", comment);
    });
  };

  Diaspora.Widgets.CommentStream = CommentStream;
})();