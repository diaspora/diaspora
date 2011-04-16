/*   Copyright (c) 2010, Diaspora Inc.  This file is
 *   licensed under the Affero General Public License version 3 or later.  See
 *   the COPYRIGHT file.
 */

Diaspora.widgets.add("i18n", function() {
  this.language = "en";
  this.locale = { };

  this.loadLocale = function(locale, language) {
    this.language = language;
    this.locale = locale;
  };

  this.t = function(item, views) {
    var ret,
      _item = item.split(".");
    
    while(part = _item.shift()) {
      ret = (ret) ? ret[part] : this.locale[part];
      if(typeof ret === "undefined") {
        return "";
      }
    }

    if(typeof views === "object") {
      return $.mustache(ret, views || {});
    }
    
    return ret;
  };
});