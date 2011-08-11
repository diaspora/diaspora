(function() {
  var StreamElement = function() {
    var self = this;
    
    this.subscribe("widget/ready", function(evt, element) {
      self.postGuid = element.attr("id");

      $.extend(self, {
        commentStream: self.instantiate("CommentStream", element.find("ul.comments")),
        embedder: self.instantiate("Embedder", element.find("div.content")),
        likes: self.instantiate("Likes", element.find("div.likes_container")),
        lightBox: self.instantiate("Lightbox", element),
        timeAgo: self.instantiate("TimeAgo", element.find("abbr.timeago"))
      });

      self.globalSubscribe("post/" + self.postGuid + "/comment/added", function(evt, comment) {
         self.commentStream.publish("comment/added", comment);
       });
    });
  };

  Diaspora.Widgets.StreamElement = StreamElement;
})();


