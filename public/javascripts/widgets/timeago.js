/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

Diaspora.widgets.add("timeago", function() {
  this.selector = "abbr.timeago";
  this.start = function() {
    Diaspora.widgets.subscribe("stream/scrolled", this.updateTimeAgo);
    Diaspora.widgets.subscribe("stream/reloaded", this.updateTimeAgo);

    if(Diaspora.widgets.i18n.language !== "en") {
      $.each($.timeago.settings.strings, function(index, element) {
        $.timeago.settings.strings[index] = Diaspora.widgets.i18n.t("timeago." + index);
      });
    }
  };

  this.updateTimeAgo = function(selector) {
    $((typeof selector === "string") ? selector : Diaspora.widgets.timeago.selector).timeago();
  };
});
