/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
 Diaspora.I18n = {
   language: "en",
   locale: {},

   loadLocale: function(locale, language) {
     this.locale = locale;
     this.language = language;
   },

   t: function(item, views) {
    var translatedMessage,
		  items = item.split(".");

    while(nextNamespace = items.shift()) {
      translatedMessage = (translatedMessage)
        ? translatedMessage[nextNamespace]
        : this.locale[nextNamespace];

      if(typeof translatedMessage === "undefined") {
        return "";
      }
    }

    return $.mustache(translatedMessage, views || { });
   }
 };