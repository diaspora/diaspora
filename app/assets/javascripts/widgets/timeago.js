/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
(function() {
  Diaspora.Widgets.TimeAgo = function() {
    var self = this;

    this.subscribe("widget/ready", function() {
      if(Diaspora.I18n.language !== "en") {
        $.timeago.settings.lang = Diaspora.I18n.language;
        $.timeago.settings.strings[Diaspora.I18n.language] = {}
        $.each($.timeago.settings.strings["en"], function(index) {
          if(index == "numbers") {
            $.timeago.settings.strings[Diaspora.I18n.language][index] = [];
          }
          else {
            $.timeago.settings.strings[Diaspora.I18n.language][index] = Diaspora.I18n.t("timeago." + index);
          }
        });
      }
    });
  };
})();
