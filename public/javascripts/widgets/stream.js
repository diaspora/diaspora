(function() {
  var Stream = function() {
    var self = this;
    this.streamElements = [];

    this.subscribe("widget/ready", function(evt, element) {
      $.each(element.find(".stream_element"), function(index, element) {
        self.addPost($(element));
      });
    });

    this.globalSubscribe("stream/post/added", function(evt, post) {
      self.addPost(post);
    });

    this.addPost = function(post) {
      self.streamElements.push(
        self.instantiate("StreamElement", post)
      );
    };
  };

  Diaspora.Widgets.Stream = Stream;
})();