/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
(function() {
  var TimeAgo = function() {
    var self = this;
    this.selector = "abbr.timeago";

    this.subscribe("widget/ready", function(evt, element) {
      self.element = element;
      self.updateTimeAgo();

      if(Diaspora.I18n.language !== "en") {
				$.each($.timeago.settings.strings, function(index) {
	  			$.timeago.settings.strings[index] = Diaspora.I18n.t("timeago." + index);
				});
      }
    });

    this.timeAgoElement = function(selector) {
      return $((typeof selector === "string") ? selector : this.selector);
    };

    this.updateTimeAgo = function() {
      if (arguments.length > 1) {
        var newElements = Array.prototype.slice.call(arguments,1);
        $(newElements).find(self.selector).timeago();
      }
      else {
        self.timeAgoElement().timeago();
      }
    };

    this.globalSubscribe("stream/scrolled stream/reloaded", self.updateTimeAgo);
  };

  Diaspora.Widgets.TimeAgo = TimeAgo;
})();
