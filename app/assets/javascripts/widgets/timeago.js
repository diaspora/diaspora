/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
(function() {
  Diaspora.Widgets.TimeAgo = function() {
    var self = this;

    this.subscribe("widget/ready", function() {
      if(Diaspora.I18n.language !== "en") {
        $.each($.timeago.settings.strings, function(index) {
          $.timeago.settings.strings[index] = Diaspora.I18n.t("timeago." + index);
        });
      }
    });
  };
})();
