// @license magnet:?xt=urn:btih:0b31508aeb0634b347b8270c7bee4d411b5d4109&dn=agpl-3.0.txt AGPL-v3-or-Later

/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
(function() {
  Diaspora.Widgets.TimeAgo = function() {
    this.subscribe("widget/ready", function() {
      if (Diaspora.I18n.language !== "en") {
        $.timeago.settings.lang = Diaspora.I18n.language;
        $.timeago.settings.strings[Diaspora.I18n.language] = {};
        $.each($.timeago.settings.strings.en, function(index) {
          if (index === "numbers") {
            $.timeago.settings.strings[Diaspora.I18n.language][index] = [];
          } else if (index === "minutes" ||
                     index === "hours" ||
                     index === "days" ||
                     index === "months" ||
                     index === "years") {
            $.timeago.settings.strings[Diaspora.I18n.language][index] = function(value) {
              return Diaspora.I18n.t("timeago." + index, {count: value});
            };
          } else {
            $.timeago.settings.strings[Diaspora.I18n.language][index] = Diaspora.I18n.t("timeago." + index);
          }
        });
      }

      $.timeago.settings.autoDispose = false;

      $(function() {
        $("time[data-time-ago]").timeago();
      });
    });
  };
})();
// @license-end
