/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

Diaspora.widgets.add("timeago", function() {
  this.selector = "abbr.timeago";

  this.start = function() {
    InfiniteScroll.postScroll(function(){
      Diaspora.widgets.timeago.updateTimeAgo();
    });

    if(Diaspora.widgets.i18n.language === "en") {
      return;
    }

    $.each($.timeago.settings.strings, function(index, element) {
      $.timeago.settings.strings[index] = Diaspora.widgets.i18n.t("timeago." + element);
    });


    Diaspora.widgets.timeago.updateTimeAgo("abbr");
  };

  this.updateTimeAgo = function(selector) {
    $(selector || this.selector).timeago();
  };
});
