(function() {
  var StreamElement = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, element) {
      if( Diaspora.backboneEnabled() ){ return }

      $.extend(self, {
        timeAgo: self.instantiate("TimeAgo", element.find(".timeago a abbr.timeago")),
        content: element.find(".content .collapsible"),
      });

      // collapse long posts
      self.content.expander({
        slicePoint: 400,
        widow: 12,
        expandText: Diaspora.I18n.t("show_more"),
        userCollapse: false
      });
    });
  };

  Diaspora.Widgets.StreamElement = StreamElement;
})();
