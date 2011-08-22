(function() {
  var Stream = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, stream) {
      $.extend(self, {
        stream: $(stream),
        streamElements: {}
      });

      $.each(self.stream.find(".stream_element"), function() {
        self.addPost($(this));
      });
    });

    this.globalSubscribe("stream/reloaded", function() {
      self.publish("widget/ready", self.stream);
    });

    this.globalSubscribe("stream/post/added", function(evt, post) {
      self.addPost(post);
    });

    this.addPost = function(post) {
      self.streamElements[post.attr("id")] = self.instantiate("StreamElement", post);
    };
  };

  Diaspora.Widgets.Stream = Stream;
})();