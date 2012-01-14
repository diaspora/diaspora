/*   Copyright (c) 2010-2011, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
 Diaspora.I18n = {
   language: "en",
   locale: {},

   loadLocale: function(locale, language) {
     this.locale = locale;
     this.language = language;
     rule = this.t('pluralization_rule');
     if (rule === "")
      rule = 'function (n) { return n == 1 ? "one" : "other" }';
     eval("this.pluralizationKey = "+rule);
   },

   t: function(item, views) {
    var items = item.split("."),
      translatedMessage,
      nextNamespace;

    while(nextNamespace = items.shift()) {
      translatedMessage = (translatedMessage)
        ? translatedMessage[nextNamespace]
        : this.locale[nextNamespace];

      if(typeof translatedMessage === "undefined") {
        return "";
      }
    }
    
    if(views && typeof views.count !== "undefined") {
      translatedMessage = translatedMessage[this.pluralizationKey(views.count)];
    }
    
    return _.template(translatedMessage, views || {});
   }
 };
