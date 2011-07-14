/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */
(function() {
  var I18n = function() {
    var self = this;
    this.locale = { };
    this.language = "en";
    
    this.loadLocale = function(locale, language) {
      this.locale = locale;
      this.language = language;
    };
   
    this.t = function(item, views) {
      var translatedMessage,
	items = item.split(".");

      while(nextNamespace = items.shift()) {
	translatedMessage = (translatedMessage) 
	  ? translatedMessage[nextNamespace]
	  : self.locale[nextNamespace];

	if(typeof translatedMessage === "undefined") {
	  return "";
	}
      }
      
      return $.mustache(translatedMessage, views || { });
    }; 
  };

  Diaspora.widgets.add("i18n", I18n);
})();
