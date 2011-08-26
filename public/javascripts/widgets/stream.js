(function() {
  var Stream = function() {
    var self = this;
    this.streamElements = {};

    this.subscribe("widget/ready", function(evt, stream) {
      $.extend(self, {
        stream: $(stream)
      });

      $.each(self.stream.find(".stream_element"), function() {
        var post = $(this);
        if(typeof self.streamElements[post.attr("id")] === "undefined") {
          self.addPost(post);
        }
      });
    });

    this.globalSubscribe("stream/reloaded", function() {
      self.streamElements = {};
    });

    this.globalSubscribe("stream/reloaded stream/scrolled", function() {
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