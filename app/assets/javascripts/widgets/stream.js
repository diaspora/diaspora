// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

(function() {
  var Stream = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, stream) {
      if( Diaspora.backboneEnabled() ){ return }

      $.extend(self, {
        stream: $(stream),
        mainStream: $(stream).find('#main_stream'),
        headerTitle: $(stream).find('#aspect_stream_header > h3')
      });
    });

    this.globalSubscribe("stream/reloaded stream/scrolled", function() {
      self.publish("widget/ready", self.stream);
    });

    this.empty = function() {
      self.mainStream.empty();
      self.headerTitle.text(Diaspora.I18n.t('stream.no_aspects'));
    };

    this.setHeaderTitle = function(newTitle) {
      self.headerTitle.text(newTitle);
    };
  };

  if(!Diaspora.backboneEnabled()) {
    Diaspora.Widgets.Stream = Stream;
  }
})();
// @license-end

