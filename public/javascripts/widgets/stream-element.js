(function() {
  var StreamElement = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, element) {
      self.postGuid = element.attr("id");

      $.extend(self, {
        commentForm: self.instantiate("CommentForm", element.find("form.new_comment")),
        commentStream: self.instantiate("CommentStream", element.find("ul.comments")),
        embedder: self.instantiate("Embedder", element.find("div.content")),
        likes: self.instantiate("Likes", element.find("div.likes_container")),
        lightBox: self.instantiate("Lightbox", element),
        deletePostLink: element.find("a.stream_element_delete"),
        hidePostLoader: element.find("img.hide_loader"),
        hidePostUndo: element.find("a.stream_element_hide_undo"),
        postScope: element.find("span.post_scope"),
        content: element.find(".content p")
      });

      // tipsy tooltips
      self.deletePostLink.tipsy({ trigger: "hover" });
      self.postScope.tipsy({ trigger: "hover" });

      // collapse long posts
      self.content.expander({
        slicePoint: 400,
        widow: 12,
        expandText: Diaspora.I18n.t("show_more"),
        userCollapse: false
      });

      self.deletePostLink.bind("click", function(evt) {
        self.deletePostLink.toggleClass("hidden");
        self.hidePostLoader.toggleClass("hidden");
      });

      self.hidePostUndo.bind("click", function(evt) {
        self.hidePostLoader.toggleClass("hidden");
      });

      self.globalSubscribe("post/" + self.postGuid + "/comment/added", function(evt, comment) {
        self.commentStream.publish("comment/added", comment);
      });

      self.globalSubscribe("commentStream/" + self.postGuid + "/loaded", function(evt) {
        self.commentStream.instantiateCommentWidgets();
      });
    });
  };

  Diaspora.Widgets.StreamElement = StreamElement;
})();
