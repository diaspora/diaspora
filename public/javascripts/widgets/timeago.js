/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
(function() {
  if(Diaspora.I18n.language !== "en") {
    $.each($.timeago.settings.strings, function(index) {
      $.timeago.settings.strings[index] = Diaspora.I18n.t("timeago." + index);
    });
  }

  Diaspora.Widgets.TimeAgo = function() {
    var self = this;

    this.subscribe("widget/ready", function(evt, element) {
      self.element = element.timeago();
    });
  };
})();
