/**
 * Created by .
 * User: dan
 * Date: Jan 25, 2011
 * Time: 8:49:02 PM
 * To change this template use File | Settings | File Templates.
 */
Diaspora.widgets.add("timeago", function() {
  this.selector = "abbr.timeago";

  this.start = function() {
      if(Diaspora.widgets.i18n.language === "en") {
        return;
      }
    
      jQuery.timeago.settings.strings = {
        prefixAgo: Diaspora.widgets.i18n.t("timeago.prefixAgo"),
        prefixFromNow: Diaspora.widgets.i18n.t("timeago.prefixFromNow"),
        suffixAgo: Diaspora.widgets.i18n.t("timeago.suffixAgo"),
        suffixFromNow: Diaspora.widgets.i18n.t("timeago.suffixFromNow"),
        seconds: Diaspora.widgets.i18n.t("timeago.seconds"),
        minute: Diaspora.widgets.i18n.t("timeago.minute"),
        minutes: Diaspora.widgets.i18n.t("timeago.minutes"),
        hour: Diaspora.widgets.i18n.t("timeago.hour"),
        hours: Diaspora.widgets.i18n.t("timeago.hours"),
        day: Diaspora.widgets.i18n.t("timeago.day"),
        days: Diaspora.widgets.i18n.t("timeago.days"),
        month: Diaspora.widgets.i18n.t("timeago.month"),
        months: Diaspora.widgets.i18n.t("timeago.months"),
        year: Diaspora.widgets.i18n.t("timeago.year"),
        years: Diaspora.widgets.i18n.t("timeago.years")
      };
      
      Diaspora.widgets.timeago.updateTimeAgo("abbr");
  };

  this.updateTimeAgo = function(selector) {
    $(selector || this.selector).timeago();
  };
});