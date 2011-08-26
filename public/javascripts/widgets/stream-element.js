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
        postScope: element.find("span.post_scope")
      });

      self.deletePostLink.tipsy({ trigger: "hover" });
      self.postScope.tipsy({ trigger: "hover" });

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
