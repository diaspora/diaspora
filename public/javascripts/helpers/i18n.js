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
      nextNamespace = ["zero", "one", "few", "few"][views.count] || "many"
      translatedMessage = translatedMessage[nextNamespace];
    }

    return $.mustache(translatedMessage, views || {});
   }
 };
