(function() {
  var Stream = function() {
    var self = this;
    this.streamElements = {};

    this.subscribe("widget/ready", function(evt, stream) {
      $.extend(self, {
        stream: $(stream),
        mainStream: $(stream).find('#main_stream'),
        headerTitle: $(stream).find('#aspect_stream_header > h3')
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

    this.empty = function() {
      self.mainStream.empty();
      self.headerTitle.text(Diaspora.I18n.t('stream.no_aspects'));
    };

    this.setHeaderTitle = function(newTitle) {
      self.headerTitle.text(newTitle);
    };
  };

  Diaspora.Widgets.Stream = Stream;
})();