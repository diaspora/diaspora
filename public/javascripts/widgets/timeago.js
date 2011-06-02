/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

Diaspora.widgets.add("timeago", function() {
  this.selector = "abbr.timeago";
  this.start = function() {
    Diaspora.widgets.subscribe("stream/scrolled", this.updateTimeAgo, this);
    Diaspora.widgets.subscribe("stream/reloaded", this.updateTimeAgo, this);

    if(this.timeAgoElement().length) {
      this.updateTimeAgo();
    }

    if(Diaspora.widgets.i18n.language !== "en") {
      $.each($.timeago.settings.strings, function(index) {
        $.timeago.settings.strings[index] = Diaspora.widgets.i18n.t("timeago." + index);
      });
    }
  };

  this.timeAgoElement = function(selector) {
    return $((typeof selector === "string") ? selector : this.selector);
  };

  this.updateTimeAgo = function() {
    this.timeAgoElement().timeago();
  };
});
