(function() {
  var CommentToggler = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, commentStream) {
      $.extend(self, {
        commentStream: commentStream,
        commentToggle: commentStream.siblings(".show_comments").find(".toggle_post_comments")
      });

      self.commentToggle.toggle(self.showComments, self.hideComments);
    });

    this.showComments = function(evt) {
      evt.preventDefault();

      if(self.commentStream.hasClass("loaded")) {
        self.commentToggle.html(Diaspora.I18n.t("comments.hide"));
        self.commentStream.removeClass("hidden");
      }
      else {
        $("<img/>", { alt: "loading", src: "/images/ajax-loader.gif"}).appendTo(self.commentToggle);

        $.get(self.commentToggle.attr("href"), function(data) {
          self.commentToggle.html(Diaspora.I18n.t("comments.hide"));
          self.commentStream.html(data)
            .addClass("loaded");

          self.globalPublish("commentStream/" + self.commentStream.attr("id") + "/loaded");
        });
      }
    };

    this.hideComments = function(evt) {
      evt.preventDefault();

      self.commentStream.addClass("hidden");
      self.commentToggle.html(Diaspora.I18n.t("comments.show"));
    };
  };

  Diaspora.Widgets.CommentToggler = CommentToggler;
})();