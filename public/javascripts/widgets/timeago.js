/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
(function() {
  var TimeAgo = function() {
    var self = this;
    this.selector = "abbr.timeago";
    this.subscribe("widget/ready", function() {
      Diaspora.widgets.subscribe("stream/scrolled stream/reloaded", self.updateTimeAgo, this);

      self.updateTimeAgo();

      if(Diaspora.widgets.i18n.language !== "en") {
	$.each($.timeago.settings.strings, function(index) {
	  $.timeago.settings.strings[index] = Diaspora.widgets.i18n.t("timeago." + index);
	});
      }
    });

    this.timeAgoElement = function(selector) {
      return $((typeof selector === "string") ? selector : this.selector);
    };

    this.updateTimeAgo = function() {
      self.timeAgoElement().timeago();
    };
  };
  Diaspora.widgets.add("timeago", TimeAgo);
})();
